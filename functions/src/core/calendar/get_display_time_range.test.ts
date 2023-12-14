import { DateTime } from "luxon";
import { CalendarEvent } from "../../types/calendar.js";
import { getDisplayTimeRange } from "./get_display_time_range.js";

const d = DateTime.fromObject;
const c = (
  startAt: DateTime,
  endAt: DateTime,
  isAllDay?: boolean
): CalendarEvent => ({
  startAt: startAt,
  endAt: endAt,
  title: "TITLE",
  description: "",
  location: "",
  isAllDay: isAllDay ?? false,
});

describe("getDisplayTimeRange", () => {
  test("通常イベント", () => {
    const start = d({ hour: 10 });
    const end = d({ hour: 11, minute: 30 });
    const event = c(start, end);

    expect(getDisplayTimeRange(event, d({}))).toBe("10:00 ~ 11:30");
  });

  test("複数日イベント", () => {
    const start = d({ day: 1, hour: 10 });
    const end = d({ day: 2, hour: 11, minute: 30 });
    const event = c(start, end);

    expect(getDisplayTimeRange(event, d({ day: 1 }))).toBe("10:00 ~");
    expect(getDisplayTimeRange(event, d({ day: 2 }))).toBe("~ 11:30");
  });

  test("終日イベント", () => {
    const start = d({ day: 1 });
    const end = d({ day: 2 });
    const event = c(start, end, true);

    expect(getDisplayTimeRange(event, d({}))).toBe(null);
  });
});
