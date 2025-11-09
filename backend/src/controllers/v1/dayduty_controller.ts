import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver, validator } from "hono-openapi";
import { DateTime } from "luxon";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import { AppConfig } from "../../config/app_config.js";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import {
  daydutyQuerySchema,
  daydutyResponseSchema,
} from "../../resources/v1/dayduty.js";
import { getDaydutyStuNo } from "../../services/dayduty_service.js";

import "zod-openapi/extend";

export const daydutRoutes = new Hono<AuthenticatedEnv>();

const paramSchema = z
  .object({
    groupId: z.string().openapi({ description: "グループのID" }),
  })
  .openapi({ description: "日直情報を取得する際のパラメータ" });
type DaydutyResponse = z.infer<typeof daydutyResponseSchema>;

daydutRoutes.get(
  "/:groupId/dayduty",
  describeRoute({
    description: "日直情報を取得する",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "application/json": { schema: resolver(daydutyResponseSchema) },
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
  validator("query", daydutyQuerySchema),
  authentication,
  async (c) => {
    const groupId = c.req.param("groupId");
    const { date } = c.req.valid("query");
    const uid = getCurrentUserId(c);

    try {
      // Firestore 並列クエリ: グループ存在 & 参加チェック
      const [groupSnapshot, userJoinedGroupsSnapshot] = await Promise.all([
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
      if (userJoinedGroupsSnapshot.empty) {
        throw new HTTPException(403, {
          message: "グループに参加していません。",
        });
      }

      const targetDate = date
        ? DateTime.fromISO(date, { zone: AppConfig.TIMEZONE })
        : DateTime.now().setZone(AppConfig.TIMEZONE);

      if (!targetDate.isValid) {
        throw new HTTPException(400, {
          message: "日付のフォーマットが正しくありません。",
        });
      }

      // 出席番号取得
      const stuNo = await getDaydutyStuNo(groupId, targetDate);

      // Classmate 取得
      const classmateSnapshot = await firestore
        .collection("classmates")
        .where("group_id", "==", groupId)
        .where("stuNo", "==", stuNo)
        .get();

      if (classmateSnapshot.empty) {
        throw new HTTPException(500, {
          message: "学生が見つかりません。",
        });
      }

      const classmateDoc = classmateSnapshot.docs[0];
      const classmate = {
        id: classmateDoc.id,
        ...classmateDoc.data(),
      };

      const validatedResponse = daydutyResponseSchema.parse(classmate);

      return c.json<DaydutyResponse>(validatedResponse, 200);
    } catch (error) {
      console.error("Error in dayduty controller:", error);
      throw error;
    }
  },
);
