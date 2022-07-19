import { DateTime } from "luxon";
import { isAllDay, isMultipleDays } from "../core/calendar/utils";
import { EventData } from "../types/events";

// TODO: 命名
// Event が既にあるので使えない

export class CalendarEvent {
  public startAt: DateTime;
  public endAt: DateTime;
  public title: string;
  public description: string;
  public location: string;
  public isAllDay: boolean;

  constructor(args: {
    startAt: DateTime;
    endAt: DateTime;
    title: string;
    description: string;
    location: string;
    isAllDay: boolean;
  }) {
    this.startAt = args.startAt;
    this.endAt = args.endAt;
    this.title = args.title;
    this.description = args.description;
    this.location = args.location;
    this.isAllDay = args.isAllDay;
  }

  public toJSON(): EventData {
    return {
      startAt: this.startAt.toISO(),
      endAt: this.endAt.toISO(),
      title: this.title,
      isAllDay: this.isAllDay,
    };
  }

  // 日付情報付きのタイトルを取得する
  // e.g. "Title (Day 1/10)"
  public getDisplayTitle(date: DateTime): string {
    // 日を跨ぐ場合に何日目かを表示する e.g. "Title (Day 1/10)"
    if (isMultipleDays(this)) {
      // 今日の日時取得
      const today = date.startOf("day");
      const startAtDay = this.startAt.startOf("day");
      const endAtDay = this.endAt.startOf("day");

      // 0 スタートなので +1 する
      // 開始日から何日か
      const diffToday = today.diff(startAtDay).as("days") + 1;
      // 開始日と終了日の差分 `endAt` は 終了日翌日の 0:00
      const diffEnd = endAtDay.diff(startAtDay).as("days");

      return `${this.title} (Day ${diffToday}/${diffEnd})`;
    }

    return this.title;
  }

  // 表示用の時刻情報を取得する
  // e.g. "9:00 ~ 10:00", "9:00 ~", "~ 10:00"
  public getDisplayTimeRange(date: DateTime): string | null {
    // 時間指定のあるイベントのみ表示
    if (isAllDay(this)) {
      return null;
    }

    // 開始時間と終了時間を表示 e.g. "9:00 ~ 10:00"
    // 日を跨いでいる場合には、開始/終了日にのみ表示する

    const isStartDay = this.startAt.hasSame(date, "day");
    const isEndDay = this.endAt.hasSame(date, "day");

    const startAt = isStartDay ? this.startAt.toFormat("H:mm") : "";
    const endAt = isEndDay ? this.endAt.toFormat("H:mm") : "";

    return `${startAt} ~ ${endAt}`;
  }
}
