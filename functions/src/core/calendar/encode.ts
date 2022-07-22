/* eslint-disable camelcase */
import { NEW_CalendarClass } from "../../models/class";
import { NEW_CalendarEvent } from "../../models/event";

// TODO: 統一するとか...
// firebase-functions でもエンコードされるのが気になる
// toJSON 読んでくれないんだろか

// JSON 形式にエンコードする

type EncodedCalendarClass = Omit<NEW_CalendarClass, "startAt" | "endAt"> & {
  startAt: string;
  endAt: string;
};
export const encodeCalendarClass = (
  event: NEW_CalendarClass
): EncodedCalendarClass => {
  return {
    startAt: event.startAt.toISO(),
    endAt: event.endAt.toISO(),
    title: event.title,
    period: event.period,
  };
};

type EncodedCalendarEvent = Omit<NEW_CalendarEvent, "startAt" | "endAt"> & {
  startAt: string;
  endAt: string;
};
export const encodeCalendarEvent = (
  event: NEW_CalendarEvent
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
