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
import { groupName, groupSchema } from "../../resources/v1/groups.js";

export const groupRoutes = new Hono<AuthorizedEnv>();

const paramSchema = z
  .object({
    id: z.string().meta({ description: "ID" }),
  })
  .meta({
    description: "グループのIDを指定するパラメータ",
  });

// カレンダー ID は運用者が Firestore で設定する。共通のサービスアカウントで読むので、
// 管理者が変えられると、そのアカウントが読める別のグループのカレンダーまで読めてしまう
const patchJsonSchema = groupSchema
  .omit({ id: true, classes_calendar_id: true, events_calendar_id: true })
  .extend({ name: groupName.meta({ description: "名前。50文字まで" }) })
  .partial()
  .refine((data) => Object.keys(data).length > 0)
  .meta({
    $id: "GroupPatchJson",
    description: "グループの更新に使用するJSONデータ",
  });
type GroupResponse = z.infer<typeof groupSchema>;

groupRoutes
  .get(
    "/:id",
    describeRoute({
      description: "グループを取得する",
      responses: {
        200: {
          description: "Successful response",
          content: {
            "application/json": { schema: resolver(groupSchema) },
          },
        },
        401: {
          description: "Unauthorized",
        },
        403: {
          description: "Forbidden",
        },
        404: {
          description: "Not Found",
        },
        500: {
          description: "Internal Server Error",
        },
      },
      security: [{ bearer: [] }],
    }),
    validator("param", paramSchema),
    authentication,
    authorize("group.read", groupOf("id")),
    async (c) => {
      const groupId = c.req.param("id");

      // binding が残ったまま、グループが消えていることがある
      const groupSnapshot = await firestore
        .collection("groups")
        .doc(groupId)
        .get();
      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }

      const group = groupSchema.parse({
        id: groupSnapshot.id,
        ...groupSnapshot.data(),
      });

      return c.json<GroupResponse>(group);
    },
  )
  .patch(
    "/:id",
    describeRoute({
      description: "グループを更新する",
      responses: {
        200: {
          description: "Successful response",
          content: {
            "application/json": { schema: resolver(groupSchema) },
          },
        },
        400: {
          description: "Bad Request",
        },
        401: {
          description: "Unauthorized",
        },
        403: {
          description: "Forbidden",
        },
        404: {
          description: "Not Found",
        },
        500: {
          description: "Internal Server Error",
        },
      },
      security: [{ bearer: [] }],
    }),
    validator("param", paramSchema),
    authentication,
    authorize("group.update", groupOf("id")),
    // 権限の無い相手に、本文の検証結果 (400) を先に返さない
    validator("json", patchJsonSchema),
    async (c) => {
      const groupId = c.req.param("id");
      const data = c.req.valid("json");

      const groupRef = firestore.collection("groups").doc(groupId);

      // binding が残ったまま、グループが消えていることがある
      const groupSnapshot = await groupRef.get();
      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }

      await groupRef.update(data);

      const updatedGroupSnapshot = await groupRef.get();
      const updatedGroup = groupSchema.parse({
        id: updatedGroupSnapshot.id,
        ...updatedGroupSnapshot.data(),
      });

      return c.json<GroupResponse>(updatedGroup);
    },
  );
