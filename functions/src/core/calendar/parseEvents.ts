import type { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import type { CalendarEvent } from "../../types/calendar.js";
import { removeCountdownPattern } from "../events/countdown_event.js";
import { parseEventDate } from "./parseEventDate.js";

export const parseEvents = (
  items: CalendarV3.Schema$Event[],
): CalendarEvent[] => {
  return items.map((v) => {
    const date = parseEventDate(v);

    return {
      startAt: date.start,
      endAt: date.end,
      title: v.summary || "(No title)",
      description: removeCountdownPattern(v.description || ""),
      location: v.location || "",
      isAllDay: v.start?.dateTime === undefined,
    };
  });
};
