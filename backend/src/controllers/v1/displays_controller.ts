import { Hono } from "hono";
import { describeRoute, resolver, validator } from "hono-openapi";
import { HTTPException } from "hono/http-exception";
import { z } from "zod";

import { firestore } from "../../clients/firebase.js";
import { authentication } from "../../middlewares/authenticate.js";
import {
  type AuthorizedEnv,
  authorize,
  groupOf,
} from "../../middlewares/authorize.js";
import {
  displayCreateJsonSchema,
  displayPatchJsonSchema,
  displaySchema,
  displaysSchema,
} from "../../resources/v1/displays.js";
import {
  listDisplays,
  registerDisplay,
  removeDisplay,
  renameDisplay,
} from "../../services/display_service.js";

export const displaysRoutes = new Hono<AuthorizedEnv>();

const groupParamSchema = z.object({
  groupId: z.string().meta({ description: "グループのID" }),
});

const displayParamSchema = groupParamSchema.extend({
  displayId: z.string().meta({ description: "教室ディスプレイのID" }),
});

type DisplayResponse = z.infer<typeof displaySchema>;
type DisplaysResponse = z.infer<typeof displaysSchema>;

const errors = {
  401: { description: "Unauthorized" },
  403: { description: "Forbidden" },
  404: { description: "Not Found" },
  500: { description: "Internal Server Error" },
};

// binding が残ったまま、グループが消えていることがある
const assertGroupExists = async (groupId: string) => {
  const snapshot = await firestore.collection("groups").doc(groupId).get();
  if (!snapshot.exists) {
    throw new HTTPException(404, { message: "グループが存在しません。" });
  }
};

displaysRoutes
  .get(
    "/:groupId/displays",
    describeRoute({
      description: "グループの教室ディスプレイを一覧する",
      responses: {
        200: {
          description: "Successful response",
          content: {
            "application/json": { schema: resolver(displaysSchema) },
          },
        },
        ...errors,
      },
      security: [{ bearer: [] }],
    }),
    validator("param", groupParamSchema),
    authentication,
    authorize("role_binding.read", groupOf("groupId")),
    async (c) => {
      const groupId = c.req.param("groupId");
      await assertGroupExists(groupId);

      return c.json<DisplaysResponse>({ items: await listDisplays(groupId) });
    },
  )
  .post(
    "/:groupId/displays",
    describeRoute({
      description:
        "端末に出ているコードで、教室ディスプレイとして登録する。端末には group.read と member.read だけが付く",
      responses: {
        201: {
          description: "Created",
          content: {
            "application/json": { schema: resolver(displaySchema) },
          },
        },
        400: { description: "Bad Request" },
        ...errors,
        404: { description: "グループが無いか、コードが無いか期限切れ" },
        429: { description: "コードを外した回数が多すぎる" },
      },
      security: [{ bearer: [] }],
    }),
    validator("param", groupParamSchema),
    authentication,
    authorize("role_binding.create", groupOf("groupId")),
    // 権限の無い相手に、本文の検証結果 (400) を先に返さない
    validator("json", displayCreateJsonSchema),
    async (c) => {
      const groupId = c.req.param("groupId");
      const { code, name } = c.req.valid("json");
      await assertGroupExists(groupId);

      const result = await registerDisplay({
        callerUid: c.get("currentUserId"),
        groupId,
        code,
        name,
      });
      if (!result.ok) {
        throw result.reason === "too_many_attempts"
          ? new HTTPException(429, {
              message: "しばらく待ってから入力し直してください。",
            })
          : new HTTPException(404, {
              message: "コードが見つからないか、期限が切れています。",
            });
      }

      return c.json<DisplayResponse>(result.display, 201);
    },
  )
  .patch(
    "/:groupId/displays/:displayId",
    describeRoute({
      description: "教室ディスプレイの名前を変える",
      responses: {
        200: {
          description: "Successful response",
          content: {
            "application/json": { schema: resolver(displaySchema) },
          },
        },
        400: { description: "Bad Request" },
        ...errors,
      },
      security: [{ bearer: [] }],
    }),
    validator("param", displayParamSchema),
    authentication,
    authorize("display.update", groupOf("groupId")),
    validator("json", displayPatchJsonSchema),
    async (c) => {
      const { groupId, displayId } = c.req.param();
      const { name } = c.req.valid("json");
      await assertGroupExists(groupId);

      const display = await renameDisplay({ groupId, displayId, name });
      if (!display) {
        throw new HTTPException(404, {
          message: "教室ディスプレイが存在しません。",
        });
      }

      return c.json<DisplayResponse>(display);
    },
  )
  .delete(
    "/:groupId/displays/:displayId",
    describeRoute({
      description:
        "教室ディスプレイを外す。ほかに付与の無い匿名アカウントは、アカウントごと消す",
      responses: {
        204: { description: "外した" },
        ...errors,
      },
      security: [{ bearer: [] }],
    }),
    validator("param", displayParamSchema),
    authentication,
    authorize("role_binding.delete", groupOf("groupId")),
    async (c) => {
      const { groupId, displayId } = c.req.param();
      await assertGroupExists(groupId);

      if ((await removeDisplay({ groupId, displayId })) === "not_found") {
        throw new HTTPException(404, {
          message: "教室ディスプレイが存在しません。",
        });
      }

      return c.body(null, 204);
    },
  );
