import { Hono } from "hono";
import { describeRoute } from "hono-openapi";
import { resolver, validator } from "hono-openapi/zod";
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
        return c.json({ error: "Group not found" }, 404);
      }

      // グループ参加チェック
      const userJoinedGroupsSnapshot = await firestore
        .collection("user_joined_groups")
        .where("user_id", "==", user.uid)
        .where("group_id", "==", groupId)
        .get();

      if (userJoinedGroupsSnapshot.empty) {
        return c.json({ error: "Forbidden" }, 403);
      }

      const targetDate = date
        ? DateTime.fromISO(date, { zone: "Asia/Tokyo" })
        : DateTime.now().setZone("Asia/Tokyo");

      if (!targetDate.isValid) {
        return c.json({ error: "Invalid date format" }, 400);
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
        return c.json({ error: "Student not found" }, 500);
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

      if (error instanceof Error) {
        if (
          error.message.includes("start date not set") ||
          error.message.includes("No students found")
        ) {
          return c.json({ error: error.message }, 500);
        }
      }

      return c.json({ error: "Internal server error" }, 500);
    }
  },
);
