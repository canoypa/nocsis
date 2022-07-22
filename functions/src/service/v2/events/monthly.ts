import { HttpsError } from "firebase-functions/v1/https";
import { DateTime } from "luxon";
import { fetchCalendar } from "../../../core/calendar";
import { encodeCalendarEvent } from "../../../core/calendar/encode";
import { parseEvents } from "../../../core/calendar/parseEvents";
import { EventData } from "../../../types/events";
import { OnCallHandler } from "../../../types/functions";

type MonthlyEventsResponse = { month: string; items: EventData[] }[];

const monthly: OnCallHandler<MonthlyEventsResponse> = async (data, context) => {
  if (!context.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be authenticated to use this function"
    );
  }

  const date = DateTime.fromISO(data.date, { zone: "asia/tokyo" });
  if (date === null) {
    throw new HttpsError("invalid-argument", "date is not ISO format");
  }

  const calendarId = process.env.EVENTS_CALENDAR_ID;
  if (!calendarId) {
    throw new HttpsError("internal", "Internal error");
  }

  const snapshot = await fetchCalendar(calendarId, {
    timeMin: date.startOf("day"),
    timeMax: date.plus({ years: 1 }).startOf("day"),
    singleEvents: true,
    orderBy: "startTime",
  });
  if (!snapshot.items) {
    throw new HttpsError("internal", "Internal error");
  }

  const events = parseEvents(snapshot.items);

  // 月別に格納する
  const work = new Map<string, EventData[]>();

  events.forEach((event) => {
    const key = event.startAt.month.toString();

    const current = work.get(key) || [];
    current.push(encodeCalendarEvent(event));

    work.set(key, current);
  });

  // レスポンス形式への変換
  const result: MonthlyEventsResponse = Array.from(work.entries()).map(
    ([month, items]) => ({ month, items })
  );

  return result;
};
export default monthly;
