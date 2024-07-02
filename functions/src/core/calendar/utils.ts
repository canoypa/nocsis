import type { CalendarEvent } from "../../types/calendar.js";

/** 終日イベントかどうか */
export const isAllDay = (e: CalendarEvent): boolean => {
  return e.isAllDay;
};

/** 日を跨ぐかどうか */
export const isMultipleDays = (e: CalendarEvent): boolean => {
  // 終日イベントの場合、endAt は翌日の 0:00 のため +1 して判定 (雑すぎる)
  return isAllDay(e)
    ? !e.startAt.plus({ days: 1 }).hasSame(e.endAt, "day")
    : !e.startAt.hasSame(e.endAt, "day");
};
