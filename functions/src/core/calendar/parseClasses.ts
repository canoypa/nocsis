import { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import { CalendarClass } from "../../types/calendar";
import { parseEventDate } from "./parseEventDate";

export const parseClasses = (
  items: CalendarV3.Schema$Event[]
): CalendarClass[] => {
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
