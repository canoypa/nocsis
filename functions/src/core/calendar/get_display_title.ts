import { DateTime } from "luxon";
import { CalendarEvent } from "../../models/event";
import { isMultipleDays } from "./utils";

// 日付情報付きのタイトルを取得する
// e.g. "Title (Day 1/10)"
export const getDisplayTitle = (
  event: CalendarEvent,
  date: DateTime
): string => {
  // 日を跨ぐ場合に何日目かを表示する e.g. "Title (Day 1/10)"
  if (isMultipleDays(event)) {
    // 今日の日時取得
    const today = date.startOf("day");
    const startAtDay = event.startAt.startOf("day");
    const endAtDay = event.endAt.startOf("day");

    // 0 スタートなので +1 する
    // 開始日から何日か
    const diffToday = today.diff(startAtDay).as("days") + 1;
    // 開始日と終了日の差分 `endAt` は 終了日翌日の 0:00
    const diffEnd = endAtDay.diff(startAtDay).as("days");

    return `${event.title} (Day ${diffToday}/${diffEnd})`;
  }

  return event.title;
};
