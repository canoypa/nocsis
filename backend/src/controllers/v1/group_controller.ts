import { Hono } from "hono";
import { describeRoute, resolver, validator } from "hono-openapi";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
} from "../../middlewares/authenticate.js";
import {
  type GroupAuthzEnv,
  requireGroupMembership,
  requireGroupRole,
} from "../../middlewares/authorize.js";
import { groupSchema } from "../../resources/v1/groups.js";

import "zod-openapi/extend";

export const groupRoutes = new Hono<AuthenticatedEnv & GroupAuthzEnv>();

// 認証を検証より先に実行する（未認証は 401、検証エラー 400 より優先）
groupRoutes.use("*", authentication);

const paramSchema = z
  .object({
    id: z.string().openapi({ description: "ID" }),
  })
  .openapi({
    description: "グループのIDを指定するパラメータ",
  });

const patchJsonSchema = groupSchema
  .omit({ id: true })
  .partial()
  .refine((data) => Object.keys(data).length > 0)
  .openapi({
    ref: "GroupPatchJson",
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
    requireGroupMembership({ param: "id" }),
    async (c) => {
      const group = groupSchema.parse(c.get("group"));

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
    validator("json", patchJsonSchema),
    // グループ設定の更新は admin ロールのみ許可する
    requireGroupRole("admin", "id"),
    async (c) => {
      const groupId = c.req.param("id");
      const data = c.req.valid("json");

      const groupRef = firestore.collection("groups").doc(groupId);

      await groupRef.update(data);

      const updatedGroupSnapshot = await groupRef.get();
      const updatedGroup = groupSchema.parse({
        id: updatedGroupSnapshot.id,
        ...updatedGroupSnapshot.data(),
      });

      return c.json<GroupResponse>(updatedGroup);
    },
  );
