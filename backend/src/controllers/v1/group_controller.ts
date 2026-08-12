import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver, validator } from "hono-openapi";
import { z } from "zod";
import {
  type AuthorizedEnv,
  authorize,
  groupOf,
} from "../../authz/middleware.js";
import { firestore } from "../../clients/firebase.js";
import { authentication } from "../../middlewares/authenticate.js";
import { groupSchema } from "../../resources/v1/groups.js";

export const groupRoutes = new Hono<AuthorizedEnv>();

const paramSchema = z
  .object({
    id: z.string().meta({ description: "ID" }),
  })
  .meta({
    description: "グループのIDを指定するパラメータ",
  });

const patchJsonSchema = groupSchema
  .omit({ id: true })
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
    validator("json", patchJsonSchema),
    authentication,
    authorize("group.update", groupOf("id")),
    async (c) => {
      const groupId = c.req.param("id");
      const data = c.req.valid("json");

      const groupRef = firestore.collection("groups").doc(groupId);

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
