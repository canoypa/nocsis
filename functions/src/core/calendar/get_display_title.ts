import { DateTime, Interval } from "luxon";
import { CalendarEvent } from "../../types/calendar.js";
import { isMultipleDays } from "./utils.js";

/**
 * 日付情報付きのタイトルを取得する
 * e.g. "Title (Day 1/10)"
 */
export const getDisplayTitle = (
  event: CalendarEvent,
  date: DateTime,
): string => {
  // 以下の場合何日目か付けて返す
  // 表示対象になる複数日のイベント
  // date がイベント期間内
  if (
    isMultipleDays(event) &&
    Interval.fromDateTimes(
      event.startAt.startOf("day"),
      event.endAt.minus(1),
    ).contains(date)
  ) {
    // date が範囲内になるよう startOf("day") している
    const elapsedDays =
      Interval.fromDateTimes(
        event.startAt.startOf("day"),
        date.startOf("day"),
      ).count("days") + 1;

    // endAt の時刻は含まないので、とりあえず -1 しておく
    const eventDays = Interval.fromDateTimes(
      event.startAt,
      event.endAt.minus(1),
    ).count("days");

    return `${event.title} (Day ${elapsedDays}/${eventDays})`;
  }

  return event.title;
};
