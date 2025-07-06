import assert from "node:assert";
import { Hono } from "hono";
import { describeRoute } from "hono-openapi";
import { resolver, validator } from "hono-openapi/zod";
import { HTTPException } from "hono/http-exception";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
  getUser,
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
      validateResponse: true,
    }),
    validator("param", paramSchema),
    authentication,
    async (c) => {
      const groupId = c.req.param("id");

      const user = getUser(c);

      const groupSnapshot = await firestore
        .collection("groups")
        .doc(groupId)
        .get();
      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }

      const userJoinedGroupSnapshot = await firestore
        .collection("user_joined_groups")
        .where("user_id", "==", user.uid)
        .where("group_id", "==", groupId)
        .get();
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
      validateResponse: true,
    }),
    validator("param", paramSchema),
    validator("json", patchJsonSchema),
    authentication,
    async (c) => {
      const groupId = c.req.param("id");
      const data = c.req.valid("json");

      const user = getUser(c);

      const groupRef = firestore.collection("groups").doc(groupId);

      const groupSnapshot = await groupRef.get();
      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }

      const userJoinedGroupSnapshot = await firestore
        .collection("user_joined_groups")
        .where("user_id", "==", user.uid)
        .where("group_id", "==", groupId)
        .get();
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
