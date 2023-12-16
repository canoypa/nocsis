import { DateTime } from "luxon";
import { CalendarEvent } from "../../types/calendar.js";
import { isAllDay } from "./utils.js";

/**
 * 表示用の時刻情報を取得する
 * e.g. "9:00 ~ 10:00", "9:00 ~", "~ 10:00"
 */
export const getDisplayTimeRange = (
  event: CalendarEvent,
  date: DateTime
): string | null => {
  // 時間指定のあるイベントの場合のみ返す
  if (isAllDay(event)) {
    return null;
  }

  // 開始時間と終了時間を表示 e.g. "9:00 ~ 10:00"
  // 日を跨いでいる場合には、開始/終了日にのみ表示する

  const isStartDay = event.startAt.hasSame(date, "day");
  const isEndDay = event.endAt.hasSame(date, "day");

  const startAt = event.startAt.toFormat("H:mm");
  const endAt = event.endAt.toFormat("H:mm");

  if (isStartDay && !isEndDay) {
    return `${startAt} ~`;
  }

  if (!isStartDay && isEndDay) {
    return `~ ${endAt}`;
  }

  return `${startAt} ~ ${endAt}`;
};
