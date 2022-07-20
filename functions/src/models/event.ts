import { DateTime } from "luxon";
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
}
