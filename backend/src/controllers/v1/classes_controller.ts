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
import { classSchema } from "../../resources/v1/classes.js";
import { fetchGoogleCalendarEvents } from "../../services/google_calendar_service.js";

import "zod-openapi/extend";

export const classesRoutes = new Hono<AuthenticatedEnv & GroupAuthzEnv>();

// 認証を検証より先に実行する
classesRoutes.use("*", authentication);

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
type ClassesResponse = z.infer<typeof classesResponseSchema>;

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
  }),
  validator("param", paramSchema),
  validator("query", querySchema),
  requireGroupMembership(),
  async (c) => {
    const { from: fromStr, to: toStr } = c.req.valid("query");

    const from = DateTime.fromISO(fromStr, { zone: AppConfig.TIMEZONE });
    const to = DateTime.fromISO(toStr, { zone: AppConfig.TIMEZONE });

    if (!from.isValid || !to.isValid) {
      throw new HTTPException(400, {
        message: "日付のフォーマットが正しくありません。",
      });
    }

    const group = c.get("group");

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
      // Google Calendar から取得した日時を DateTime で統一処理
      const startDate = item.start?.dateTime || item.start?.date;
      const endDate = item.end?.dateTime || item.end?.date;

      if (!startDate || !endDate) {
        throw new HTTPException(500, {
          message: "イベントの開始日時または終了日時が取得できませんでした。",
        });
      }

      const startAt = DateTime.fromISO(startDate, {
        zone: AppConfig.TIMEZONE,
      });
      const endAt = DateTime.fromISO(endDate, { zone: AppConfig.TIMEZONE });

      if (!startAt.isValid || !endAt.isValid) {
        throw new HTTPException(500, {
          message: "日時の変換に失敗しました。",
        });
      }

      return classSchema.parse({
        startAt: startAt.toISO(),
        endAt: endAt.toISO(),
        title: item.summary,
        period: index + 1,
      });
    });

    return c.json<ClassesResponse>({
      items: classes,
    });
  },
);
