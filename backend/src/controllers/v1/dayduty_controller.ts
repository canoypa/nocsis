import { Hono } from "hono";
import { describeRoute } from "hono-openapi";
import { resolver, validator } from "hono-openapi/zod";
import { HTTPException } from "hono/http-exception";
import { DateTime } from "luxon";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
  getUser,
} from "../../middlewares/authenticate.js";
import {
  daydudyQuerySchema,
  daydudyResponseSchema,
} from "../../resources/v1/dayduty.js";
import { getDaydutyStuNo } from "../../services/dayduty_service.js";

import "zod-openapi/extend";

export const daydutRoutes = new Hono<AuthenticatedEnv>();

const paramSchema = z
  .object({
    groupId: z.string().openapi({ description: "グループのID" }),
  })
  .openapi({ description: "日直情報を取得する際のパラメータ" });

daydutRoutes.get(
  "/:groupId/dayduty",
  describeRoute({
    description: "日直情報を取得する",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "application/json": { schema: resolver(daydudyResponseSchema) },
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
  validator("query", daydudyQuerySchema),
  authentication,
  async (c) => {
    const groupId = c.req.param("groupId");
    const { date } = c.req.valid("query");
    const user = getUser(c);

    try {
      // グループ存在チェック
      const groupSnapshot = await firestore
        .collection("groups")
        .doc(groupId)
        .get();
      if (!groupSnapshot.exists) {
        throw new HTTPException(404, { message: "グループが存在しません。" });
      }

      // グループ参加チェック
      const userJoinedGroupsSnapshot = await firestore
        .collection("user_joined_groups")
        .where("user_id", "==", user.uid)
        .where("group_id", "==", groupId)
        .get();

      if (userJoinedGroupsSnapshot.empty) {
        throw new HTTPException(403, {
          message: "グループに参加していません。",
        });
      }

      const targetDate = date
        ? DateTime.fromISO(date, { zone: "Asia/Tokyo" })
        : DateTime.now().setZone("Asia/Tokyo");

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

      const validatedResponse = daydudyResponseSchema.parse(classmate);

      return c.json(validatedResponse, 200);
    } catch (error) {
      console.error("Error in dayduty controller:", error);
      throw error;
    }
  },
);
