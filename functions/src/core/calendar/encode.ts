import { CalendarClass, CalendarEvent } from "../../types/calendar";

// TODO: 統一するとか...
// firebase-functions でもエンコードされるのが気になる
// toJSON 読んでくれないんだろか

// JSON 形式にエンコードする

type EncodedCalendarClass = Omit<CalendarClass, "startAt" | "endAt"> & {
  startAt: string;
  endAt: string;
};
export const encodeCalendarClass = (
  event: CalendarClass
): EncodedCalendarClass => {
  return {
    startAt: event.startAt.toISO(),
    endAt: event.endAt.toISO(),
    title: event.title,
    period: event.period,
  };
};

type EncodedCalendarEvent = Omit<CalendarEvent, "startAt" | "endAt"> & {
  startAt: string;
  endAt: string;
};
export const encodeCalendarEvent = (
  event: CalendarEvent
): EncodedCalendarEvent => {
  return {
    startAt: event.startAt.toISO(),
    endAt: event.endAt.toISO(),
    title: event.title,
    description: event.description,
    location: event.location,
    isAllDay: event.isAllDay,
  };
};
