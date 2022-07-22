/* eslint-disable camelcase */
import { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import { NEW_CalendarClass } from "../../models/class";
import { parseEventDate } from "./parseEventDate";

export const parseClasses = (
  items: CalendarV3.Schema$Event[]
): NEW_CalendarClass[] => {
  return items.map((v, i) => {
    const date = parseEventDate(v);

    return {
      startAt: date.start,
      endAt: date.end,
      title: v.summary || "(No title)",
      period: i + 1,
    };
  });
};
