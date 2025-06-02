import { Hono } from "hono";
import { describeRoute } from "hono-openapi";
import { resolver, validator } from "hono-openapi/zod";
import { getContext } from "hono/context-storage";
import { z } from "zod";
import "zod-openapi/extend";
import assert from "node:assert";
import { getFirestore } from "firebase-admin/firestore";
import { HTTPException } from "hono/http-exception";
import { firebaseApp } from "../../clients/firebase_app.js";
import {
  type AuthenticatedEnv,
  authentication,
} from "../../middlewares/authenticate.js";

export const groupRoutes = new Hono();

const groupSchema = z
  .object({
    id: z.string().openapi({ description: "ID" }),
    name: z.string().openapi({ description: "名前" }),
    classes_calendar_id: z
      .string()
      .openapi({ description: "授業カレンダーID" }),
    events_calendar_id: z
      .string()
      .openapi({ description: "イベントカレンダーID" }),
    dayduty_start_date: z.string().openapi({ description: "日直開始日" }),
    slack_event_channel_id: z
      .string()
      .openapi({ description: "Slackイベント通知チャンネルID" }),
    weather_point: z.object({
      lat: z.number().openapi({ description: "緯度" }),
      lon: z.number().openapi({ description: "経度" }),
    }),
  })
  .openapi({ description: "グループ" });

const groupGetParamSchema = z.object({
  id: z.string().openapi({ description: "ID" }),
});

const patchGroupSchema = groupSchema.omit({ id: true }).partial();

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
    validator("param", groupGetParamSchema),
    authentication,
    async (c) => {
      const firestore = getFirestore(firebaseApp);

      const user = getContext<AuthenticatedEnv>().get("currentUser");

      const groupSnapshot = await firestore
        .collection("groups")
        .doc(c.req.param("id"))
        .get();

      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }

      const userJoinedGroupSnapshot = await firestore
        .collection("user_joined_groups")
        .where("user_id", "==", user.uid)
        .where("group_id", "==", c.req.param("id"))
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
  .post(async (_c) => {})
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
    validator("json", patchGroupSchema),
    authentication,
    async (c) => {
      const firestore = getFirestore(firebaseApp);

      const groupId = c.req.param("id");
      const user = getContext<AuthenticatedEnv>().get("currentUser");
      const data = c.req.valid("json");

      console.log(data);

      if (!data || Object.keys(data).length === 0) {
        throw new HTTPException(400, { message: "不正なデータです。" });
      }

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
  )
  .delete(async (_c) => {});
