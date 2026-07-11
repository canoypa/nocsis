import assert from "node:assert";
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver, validator } from "hono-openapi";
import { DateTime } from "luxon";
import { z } from "zod";
import { AppConfig } from "../../config/app_config.js";
import {
  type AuthenticatedEnv,
  authentication,
} from "../../middlewares/authenticate.js";
import {
  type GroupAuthzEnv,
  requireGroupMembership,
} from "../../middlewares/authorize.js";
import { eventSchema } from "../../resources/v1/events.js";
import { fetchGoogleCalendarEvents } from "../../services/google_calendar_service.js";

import "zod-openapi/extend";

export const eventsRoutes = new Hono<AuthenticatedEnv & GroupAuthzEnv>();

// 認証を検証より先に実行する
eventsRoutes.use("*", authentication);

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
    limit: z.coerce
      .number()
      .int()
      .positive({ message: "limitは正の整数である必要があります" })
      .optional()
      .openapi({ description: "取得件数上限" }),
  })
  .openapi({ description: "イベントの一覧を取得する際のクエリパラメータ" });

const eventsResponseSchema = z
  .object({
    items: z.array(eventSchema).openapi({ description: "イベントのリスト" }),
  })
  .openapi({ description: "イベントの一覧を取得する際のレスポンス" });
type EventsResponse = z.infer<typeof eventsResponseSchema>;

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
  }),
  validator("param", paramSchema),
  validator("query", querySchema),
  requireGroupMembership(),
  async (c) => {
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

    const group = c.get("group");

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

    return c.json<EventsResponse>({
      items: eventItems,
    });
  },
);
