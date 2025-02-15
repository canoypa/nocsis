import type { calendar_v3 } from "@googleapis/calendar";
import { DateTime } from "luxon";
import * as v from "valibot";
import { type InferOutput, safeParse } from "valibot";
import { fetchCalendar } from "../../core/calendar.js";

export const fetchCountdownEvents =
  async (): Promise<calendar_v3.Schema$Events> => {
    const calendarId = process.env.EVENTS_CALENDAR_ID;
    if (!calendarId) {
      throw new Error("EVENTS_CALENDAR_ID is not defined");
    }

    const events = await fetchCalendar(calendarId, {
      q: "countdown",
    });

    return events;
  };

/**
 * カウントダウンのパターン
 * event.description に設定される
 */
export const COUNTDOWN_PATTERN =
  /^countdown(\.before=(?<before>\d+)(?<unit>day|month))?$/m;

const COUNTDOWN_OPTION_SCHEMA = v.object({
  before: v.optional(
    v.pipe(
      v.string(),
      v.transform((v) => Number.parseInt(v, 10)),
      v.integer(),
    ),
  ),
  unit: v.optional(v.union([v.literal("day"), v.literal("month")])),
});

type CountDownMatch = InferOutput<typeof COUNTDOWN_OPTION_SCHEMA>;
export const matchCountdownPattern = (
  description: string,
): CountDownMatch | null => {
  const match = description.match(COUNTDOWN_PATTERN);

  if (!match) return null;

  const result = safeParse(COUNTDOWN_OPTION_SCHEMA, match.groups);
  if (!result.success) return null;

  return result.output;
};

export const isCountdownTarget = (
  event: calendar_v3.Schema$Event,
  timestampArg: DateTime<true>,
): boolean => {
  if (!event.description) return false;

  const match = matchCountdownPattern(event.description);
  if (!match) return false;

  const timestamp = timestampArg.startOf("day");

  const startDate = event.start?.dateTime || event.start?.date;
  if (!startDate) {
    throw new Error("startDate or date is not found");
  }

  const eventStartDate = DateTime.fromISO(startDate, {
    zone: "Asia/Tokyo",
  }).startOf("day");

  // オプションが指定されている場合
  if (match.before && match.unit) {
    const countdownStartDate = eventStartDate.minus({
      [match.unit]: match.before,
    });

    // カウントダウン開始日より前の場合、カウントダウン対象ではない
    const isBeforeCountdownStart =
      countdownStartDate.diff(timestamp, "days").days > 0;
    if (isBeforeCountdownStart) {
      return false;
    }
  }

  // イベント以前日より前の場合、カウントダウン対象
  const isBeforeEventStart = eventStartDate.diff(timestamp, "days").days > 0;
  return isBeforeEventStart;
};

export const removeCountdownPattern = (text: string): string => {
  return text.replace(COUNTDOWN_PATTERN, "").trim();
};
