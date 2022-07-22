import { DateTime } from "luxon";

// TODO: 命名
// Class も Event も使いにくいので Calendar と付けてる

export type CalendarClass = {
  startAt: DateTime;
  endAt: DateTime;
  title: string;
  period: number;
};

export type CalendarEvent = {
  startAt: DateTime;
  endAt: DateTime;
  title: string;
  description: string;
  location: string;
  isAllDay: boolean;
};
