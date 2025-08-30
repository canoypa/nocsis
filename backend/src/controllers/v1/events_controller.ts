import assert from "node:assert";
import { Hono } from "hono";
import { describeRoute } from "hono-openapi";
import { resolver, validator } from "hono-openapi/zod";
import { HTTPException } from "hono/http-exception";
import { DateTime } from "luxon";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import { AppConfig } from "../../config/app_config.js";
import {
  type AuthenticatedEnv,
  authentication,
  getUser,
} from "../../middlewares/authenticate.js";
import { eventSchema } from "../../resources/v1/events.js";
import { fetchGoogleCalendarEvents } from "../../services/google_calendar_service.js";

import "zod-openapi/extend";

export const eventsRoutes = new Hono<AuthenticatedEnv>();

const paramSchema = z
  .object({
    groupId: z.string().openapi({ description: "グループのID" }),
  })
  .openapi({ description: "イベントの一覧を取得する際のパラメータ" });

const querySchema = z
  .object({
    from: z
      .string()
      .datetime({ offset: true })
      .openapi({ description: "取得開始日時" }),
    to: z
      .string()
      .datetime({ offset: true })
      .optional()
      .openapi({ description: "取得終了日時" }),
    limit: z
      .string()
      .transform((val) => Number.parseInt(val, 10))
      .refine((val) => !Number.isNaN(val) && val > 0, {
        message: "limitは正の整数である必要があります",
      })
      .openapi({ description: "取得件数上限" }),
  })
  .openapi({ description: "イベントの一覧を取得する際のクエリパラメータ" });

const eventsResponseSchema = z
  .object({
    items: z.array(eventSchema).openapi({ description: "イベントのリスト" }),
  })
  .openapi({ description: "イベントの一覧を取得する際のレスポンス" });

eventsRoutes.get(
  "/:groupId/events",
  describeRoute({
    description: "イベントの一覧を取得する",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "application/json": { schema: resolver(eventsResponseSchema) },
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
    const { from: fromStr, to: toStr, limit } = c.req.valid("query");

    const from = DateTime.fromISO(fromStr, { zone: AppConfig.TIMEZONE });
    const to = toStr
      ? DateTime.fromISO(toStr, { zone: AppConfig.TIMEZONE })
      : undefined;

    if (!from.isValid || (to && !to.isValid)) {
      throw new HTTPException(400, {
        message: "日付のフォーマットが正しくありません。",
      });
    }

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

    const calendarId = group.events_calendar_id;
    if (!calendarId) {
      throw new HTTPException(500, {
        message: "グループにカレンダーIDが設定されていません。",
      });
    }

    const events = await fetchGoogleCalendarEvents(calendarId, {
      singleEvents: true,
      timeMin: from,
      timeMax: to,
      maxResults: limit,
      orderBy: "startTime",
      fields: "items(id,start,end,summary,description,location)",
    });
    assert(events.items, "イベントが存在しません。");

    const eventItems = events.items.map((item) => {
      return eventSchema.parse({
        id: item.id,
        startAt: item.start?.dateTime || item.start?.date,
        endAt: item.end?.dateTime || item.end?.date,
        title: item.summary || "",
        description: item.description,
        location: item.location,
        isAllDay: !item.start?.dateTime, // dateTimeがない場合は終日イベント
      });
    });

    return c.json({
      items: eventItems,
    });
  },
);
