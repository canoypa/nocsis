import assert from "node:assert";
import type { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver, validator } from "hono-openapi";
import { DateTime } from "luxon";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import { AppConfig } from "../../config/app_config.js";
import { authentication } from "../../middlewares/authenticate.js";
import {
  type AuthorizedEnv,
  authorize,
  groupOf,
} from "../../middlewares/authorize.js";
import { eventSchema } from "../../resources/v1/events.js";
import { fetchGoogleCalendarEvents } from "../../services/google_calendar_service.js";

const toEventTime = (time: CalendarV3.Schema$EventDateTime | undefined) =>
  time?.dateTime
    ? { dateTime: time.dateTime }
    : { date: time?.date ?? undefined };

export const eventsRoutes = new Hono<AuthorizedEnv>();

const paramSchema = z
  .object({
    groupId: z.string().meta({ description: "グループのID" }),
  })
  .meta({ description: "イベントの一覧を取得する際のパラメータ" });

const querySchema = z
  .object({
    from: z
      .string()
      .datetime({ offset: true })
      .meta({ description: "取得開始日時" }),
    to: z
      .string()
      .datetime({ offset: true })
      .optional()
      .meta({ description: "取得終了日時" }),
    limit: z.coerce
      .number()
      .int()
      .positive({ message: "limitは正の整数である必要があります" })
      .optional()
      .meta({ description: "取得件数上限" }),
  })
  .meta({ description: "イベントの一覧を取得する際のクエリパラメータ" });

const eventsResponseSchema = z
  .object({
    items: z.array(eventSchema).meta({ description: "イベントのリスト" }),
  })
  .meta({ description: "イベントの一覧を取得する際のレスポンス" });
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
  authentication,
  authorize("group.read", groupOf("groupId")),
  // 権限の無い相手に、クエリの検証結果 (400) を先に返さない
  validator("query", querySchema),
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

    // binding が残ったまま、グループが消えていることがある
    const groupSnapshot = await firestore
      .collection("groups")
      .doc(groupId)
      .get();
    if (!groupSnapshot.exists) {
      throw new HTTPException(404, { message: "グループが存在しません。" });
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

    // 1件の不備で、ほかの予定まで見えなくしない
    const eventItems = events.items.flatMap((item) => {
      const result = eventSchema.safeParse({
        id: item.id,
        startAt: item.start?.dateTime || item.start?.date,
        endAt: item.end?.dateTime || item.end?.date,
        start: toEventTime(item.start),
        end: toEventTime(item.end),
        title: item.summary || "",
        description: item.description,
        location: item.location,
        isAllDay: !item.start?.dateTime, // dateTimeがない場合は終日イベント
      });
      if (!result.success) {
        console.warn("イベントを返せないので除きます:", item.id, result.error);
        return [];
      }
      return [result.data];
    });

    return c.json<EventsResponse>({
      items: eventItems,
    });
  },
);
