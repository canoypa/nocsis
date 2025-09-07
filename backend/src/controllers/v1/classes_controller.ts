import assert from "node:assert";
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute } from "hono-openapi";
import { resolver, validator } from "hono-openapi/zod";
import { DateTime } from "luxon";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import { AppConfig } from "../../config/app_config.js";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import { classSchema } from "../../resources/v1/classes.js";
import { fetchGoogleCalendarEvents } from "../../services/google_calendar_service.js";

import "zod-openapi/extend";

export const classesRoutes = new Hono<AuthenticatedEnv>();

const paramSchema = z
  .object({
    groupId: z.string().openapi({ description: "グループのID" }),
  })
  .openapi({ description: "授業の一覧を取得する際のパラメータ" });

const querySchema = z
  .object({
    from: z
      .string()
      .datetime({ offset: true })
      .openapi({ description: "取得開始日時" }),
    to: z
      .string()
      .datetime({ offset: true })
      .openapi({ description: "取得終了日時" }),
  })
  .openapi({ description: "授業の一覧を取得する際のクエリパラメータ" });

const classesResponseSchema = z
  .object({
    items: z.array(classSchema).openapi({ description: "授業のリスト" }),
  })
  .openapi({ description: "授業の一覧を取得する際のレスポンス" });

classesRoutes.get(
  "/:groupId/classes",
  describeRoute({
    description: "授業の一覧を取得する",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "application/json": { schema: resolver(classesResponseSchema) },
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
  validator("query", querySchema),
  authentication,
  async (c) => {
    const groupId = c.req.param("groupId");
    const { from: fromStr, to: toStr } = c.req.valid("query");

    const from = DateTime.fromISO(fromStr, { zone: AppConfig.TIMEZONE });
    const to = DateTime.fromISO(toStr, { zone: AppConfig.TIMEZONE });

    if (!from.isValid || !to.isValid) {
      throw new HTTPException(400, {
        message: "日付のフォーマットが正しくありません。",
      });
    }

    const uid = getCurrentUserId(c);

    const groupSnapshot = await firestore
      .collection("groups")
      .doc(groupId)
      .get();
    if (!groupSnapshot.exists) {
      throw new HTTPException(404, { message: "グループが存在しません。" });
    }

    const userJoinedGroupSnapshot = await firestore
      .collection("user_joined_groups")
      .where("user_id", "==", uid)
      .where("group_id", "==", groupId)
      .get();
    if (userJoinedGroupSnapshot.empty) {
      throw new HTTPException(403, {
        message: "グループに参加していません。",
      });
    }

    const group = groupSnapshot.data();
    assert(group);

    const calendarId = group.classes_calendar_id;
    if (!calendarId) {
      throw new HTTPException(500, {
        message: "グループにカレンダーIDが設定されていません。",
      });
    }

    const events = await fetchGoogleCalendarEvents(calendarId, {
      singleEvents: true,
      timeMin: from,
      timeMax: to,
      orderBy: "startTime",
      fields: "items(start,end,summary)",
    });
    assert(events.items, "イベントが存在しません。");

    const classes = events.items.map((item, index) => {
      return classSchema.parse({
        startAt: item.start?.dateTime,
        endAt: item.end?.dateTime,
        title: item.summary,
        period: index + 1,
      });
    });

    return c.json({
      items: classes,
    });
  },
);
