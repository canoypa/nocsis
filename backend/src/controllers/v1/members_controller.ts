import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver, validator } from "hono-openapi";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import { authentication } from "../../middlewares/authenticate.js";
import {
  type AuthorizedEnv,
  authorize,
  groupOf,
} from "../../middlewares/authorize.js";
import {
  memberPatchJsonSchema,
  memberSchema,
  membersCreateJsonSchema,
  membersDeleteJsonSchema,
  membersOrderJsonSchema,
  membersSchema,
} from "../../resources/v1/members.js";
import {
  addMembers,
  listMembers,
  removeMembers,
  renameMember,
  reorderMembers,
} from "../../services/member_service.js";

export const membersRoutes = new Hono<AuthorizedEnv>();

const groupParamSchema = z.object({
  groupId: z.string().meta({ description: "グループのID" }),
});

const memberParamSchema = groupParamSchema.extend({
  memberId: z.string().meta({ description: "生徒のID" }),
});

type MemberResponse = z.infer<typeof memberSchema>;
type MembersResponse = z.infer<typeof membersSchema>;

const errors = {
  401: { description: "Unauthorized" },
  403: { description: "Forbidden" },
  404: { description: "Not Found" },
  500: { description: "Internal Server Error" },
};

const membersResponse = (description: string) => ({
  description,
  content: {
    "application/json": { schema: resolver(membersSchema) },
  },
});

// binding が残ったまま、グループが消えていることがある
const assertGroupExists = async (groupId: string) => {
  const snapshot = await firestore.collection("groups").doc(groupId).get();
  if (!snapshot.exists) {
    throw new HTTPException(404, { message: "グループが存在しません。" });
  }
};

membersRoutes
  .get(
    "/:groupId/members",
    describeRoute({
      description: "グループの生徒を出席番号の順に一覧する",
      responses: {
        200: membersResponse("Successful response"),
        ...errors,
      },
      security: [{ bearer: [] }],
    }),
    validator("param", groupParamSchema),
    authentication,
    authorize("member.read", groupOf("groupId")),
    async (c) => {
      const groupId = c.req.param("groupId");
      await assertGroupExists(groupId);

      return c.json<MembersResponse>({ items: await listMembers(groupId) });
    },
  )
  .post(
    "/:groupId/members",
    describeRoute({
      description: "生徒を末尾に加える。名前の順に、続きの出席番号を振る",
      responses: {
        201: membersResponse("加えた生徒"),
        400: { description: "Bad Request" },
        ...errors,
      },
      security: [{ bearer: [] }],
    }),
    validator("param", groupParamSchema),
    authentication,
    authorize("member.create", groupOf("groupId")),
    // 権限の無い相手に、本文の検証結果 (400) を先に返さない
    validator("json", membersCreateJsonSchema),
    async (c) => {
      const groupId = c.req.param("groupId");
      const { names } = c.req.valid("json");
      await assertGroupExists(groupId);

      return c.json<MembersResponse>(
        { items: await addMembers(groupId, names) },
        201,
      );
    },
  )
  .put(
    "/:groupId/members/order",
    describeRoute({
      description: "生徒を並べ替え、その順に出席番号を振り直す",
      responses: {
        200: membersResponse("並べ替えた後の全員"),
        400: { description: "Bad Request" },
        ...errors,
        409: {
          description:
            "ids がグループの生徒全員と合わない。ほかの人が足したか消した",
        },
      },
      security: [{ bearer: [] }],
    }),
    validator("param", groupParamSchema),
    authentication,
    authorize("member.update", groupOf("groupId")),
    validator("json", membersOrderJsonSchema),
    async (c) => {
      const groupId = c.req.param("groupId");
      const { ids } = c.req.valid("json");
      await assertGroupExists(groupId);

      const members = await reorderMembers(groupId, ids);
      if (members === "mismatch") {
        throw new HTTPException(409, {
          message: "生徒が変わっています。読み込み直してください。",
        });
      }

      return c.json<MembersResponse>({ items: members });
    },
  )
  .post(
    "/:groupId/members/delete",
    describeRoute({
      description: "生徒を削除し、残りの出席番号を詰めて振り直す",
      responses: {
        200: membersResponse("削除した後の全員"),
        400: { description: "Bad Request" },
        ...errors,
        404: { description: "グループが無いか、グループにいない ID がある" },
      },
      security: [{ bearer: [] }],
    }),
    validator("param", groupParamSchema),
    authentication,
    authorize("member.delete", groupOf("groupId")),
    validator("json", membersDeleteJsonSchema),
    async (c) => {
      const groupId = c.req.param("groupId");
      const { ids } = c.req.valid("json");
      await assertGroupExists(groupId);

      const members = await removeMembers(groupId, ids);
      if (members === "not_found") {
        throw new HTTPException(404, {
          message: "生徒が存在しません。",
        });
      }

      return c.json<MembersResponse>({ items: members });
    },
  )
  .patch(
    "/:groupId/members/:memberId",
    describeRoute({
      description: "生徒の名前を変える",
      responses: {
        200: {
          description: "Successful response",
          content: {
            "application/json": { schema: resolver(memberSchema) },
          },
        },
        400: { description: "Bad Request" },
        ...errors,
      },
      security: [{ bearer: [] }],
    }),
    validator("param", memberParamSchema),
    authentication,
    authorize("member.update", groupOf("groupId")),
    validator("json", memberPatchJsonSchema),
    async (c) => {
      const { groupId, memberId } = c.req.param();
      const { name } = c.req.valid("json");
      await assertGroupExists(groupId);

      const member = await renameMember(groupId, memberId, name);
      if (!member) {
        throw new HTTPException(404, { message: "生徒が存在しません。" });
      }

      return c.json<MemberResponse>(member);
    },
  );
