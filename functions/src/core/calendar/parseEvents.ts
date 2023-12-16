import { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import { CalendarEvent } from "../../types/calendar.js";
import { parseEventDate } from "./parseEventDate.js";

export const parseEvents = (
  items: CalendarV3.Schema$Event[]
): CalendarEvent[] => {
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
