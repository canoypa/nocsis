/* eslint-disable camelcase */
import { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import { NEW_CalendarEvent } from "../../models/event";
import { parseEventDate } from "./parseEventDate";

export const parseEvents = (
  items: CalendarV3.Schema$Event[]
): NEW_CalendarEvent[] => {
  return items.map((v) => {
    const date = parseEventDate(v);

    return {
      startAt: date.start,
      endAt: date.end,
      title: v.summary || "(No title)",
      description: v.description || "",
      location: v.location || "",
      isAllDay: v.start?.dateTime === undefined,
    };
  });
};
