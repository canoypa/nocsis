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
      },
      security: [{ bearer: [] }],
      validateResponse: true,
    }),
    validator("param", groupGetParamSchema),
    authentication,
    async (c) => {
      const firestore = getFirestore(firebaseApp);
      const user = getContext<AuthenticatedEnv>().get("currentUser");

      try {
        const userJoinedGroupSnapshot = await firestore
          .collection("user_joined_groups")
          .where("user_id", "==", user.uid)
          .where("group_id", "==", c.req.param("id"))
          .get();
        const userJoinedGroup = userJoinedGroupSnapshot.docs.at(0)?.data();
        assert(
          userJoinedGroup,
          "グループが存在しないか、ユーザーがグループに参加していない",
        );

        const groupSnapshot = await firestore
          .collection("groups")
          .doc(c.req.param("id"))
          .get();
        const group = groupSnapshot.data();
        assert(group, "グループが存在しない");

        return c.json({
          id: groupSnapshot.id,
          ...group,
        });
      } catch (error) {
        throw new HTTPException(404, { message: "グループが見つかりません。" });
      }
    },
  )
  .post(async (_c) => {})
  .patch(async (_c) => {})
  .delete(async (_c) => {});
