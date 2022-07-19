import { DateTime } from "luxon";
import { ClassData } from "../types/classes";

// TODO: 命名
// CalendarEvent に揃えてる

export class CalendarClass {
  public startAt: DateTime;
  public endAt: DateTime;
  public title: string;
  public period: number;

  constructor(args: {
    startAt: DateTime;
    endAt: DateTime;
    title: string;
    period: number;
  }) {
    this.startAt = args.startAt;
    this.endAt = args.endAt;
    this.title = args.title;
    this.period = args.period;
  }

  public toJSON(): ClassData {
    return {
      startAt: this.startAt.toISO(),
      endAt: this.endAt.toISO(),
      title: this.title,
      period: this.period,
    };
  }
}
