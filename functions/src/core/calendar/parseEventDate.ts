import { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import { DateTime } from "luxon";

/**
 * イベントの日時を DateTime に変換する
 */
export const parseEventDate = (
  event: CalendarV3.Schema$Event
): { start: DateTime; end: DateTime } => {
  const startDate = event.start?.dateTime || event.start?.date;
  const endDate = event.end?.dateTime || event.end?.date;

  if (!startDate || !endDate) {
    throw new Error("startDate or endDate is not found");
  }

  const start = DateTime.fromISO(startDate, { zone: "asia/tokyo" });
  const end = DateTime.fromISO(endDate, { zone: "asia/tokyo" });

  return { start, end };
};
