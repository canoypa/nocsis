import assert from "node:assert";
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver, validator } from "hono-openapi";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import { groupSchema } from "../../resources/v1/groups.js";

import "zod-openapi/extend";

export const groupRoutes = new Hono<AuthenticatedEnv>();

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
    async (c) => {
      const groupId = c.req.param("id");

      const uid = getCurrentUserId(c);

      // Firestore 並列クエリ: グループ存在 & 参加チェック
      const [groupSnapshot, userJoinedGroupSnapshot] = await Promise.all([
        firestore.collection("groups").doc(groupId).get(),
        firestore
          .collection("user_joined_groups")
          .where("user_id", "==", uid)
          .where("group_id", "==", groupId)
          .get(),
      ]);
      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }
      if (userJoinedGroupSnapshot.empty) {
        throw new HTTPException(403, {
          message: "グループに参加していません。",
        });
      }

      const group = groupSnapshot.data();
      assert(group);

      return c.json({
        id: groupSnapshot.id,
        ...group,
      });
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
    authentication,
    async (c) => {
      const groupId = c.req.param("id");
      const data = c.req.valid("json");

      const uid = getCurrentUserId(c);

      const groupRef = firestore.collection("groups").doc(groupId);

      // Firestore 並列クエリ: グループ存在 & 参加チェック
      const [groupSnapshot, userJoinedGroupSnapshot] = await Promise.all([
        groupRef.get(),
        firestore
          .collection("user_joined_groups")
          .where("user_id", "==", uid)
          .where("group_id", "==", groupId)
          .get(),
      ]);
      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }
      if (userJoinedGroupSnapshot.empty) {
        throw new HTTPException(403, {
          message: "グループに参加していません。",
        });
      }

      await groupRef.update(data);

      const updatedGroupSnapshot = await groupRef.get();
      const updatedGroup = updatedGroupSnapshot.data();
      assert(updatedGroup);

      return c.json({
        id: updatedGroupSnapshot.id,
        ...updatedGroup,
      });
    },
  );
