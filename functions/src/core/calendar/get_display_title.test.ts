import { DateTime } from "luxon";
import { CalendarEvent } from "../../models/event";
import { getDisplayTitle } from "./get_display_title";

const d = DateTime.fromObject;
const c = (startAt: DateTime, endAt: DateTime, isAllDay?: boolean) =>
  new CalendarEvent({
    startAt: startAt,
    endAt: endAt,
    title: "TITLE",
    description: "",
    location: "",
    isAllDay: isAllDay ?? false,
  });

describe("getDisplayTitle", () => {
  test("通常イベント", () => {
    const start = d({ day: 1, hour: 22 });
    const end = d({ day: 5, hour: 2 });
    const event = c(start, end);

    expect(getDisplayTitle(event, d({ day: 1 }))).toBe("TITLE (Day 1/5)");
    expect(getDisplayTitle(event, d({ day: 3 }))).toBe("TITLE (Day 3/5)");
    expect(getDisplayTitle(event, d({ day: 5 }))).toBe("TITLE (Day 5/5)");

    // 範囲外
    expect(getDisplayTitle(event, start.minus({ month: 1 }))).toBe("TITLE");
    expect(getDisplayTitle(event, end.plus({ month: 1 }))).toBe("TITLE");
  });

  test("終日イベント", () => {
    const start = d({ day: 1 });
    const end = d({ day: 6 });
    const event = c(start, end, true);

    expect(getDisplayTitle(event, d({ day: 1 }))).toBe("TITLE (Day 1/5)");
    expect(getDisplayTitle(event, d({ day: 3 }))).toBe("TITLE (Day 3/5)");
    expect(getDisplayTitle(event, d({ day: 5 }))).toBe("TITLE (Day 5/5)");

    // 範囲外
    expect(getDisplayTitle(event, start.minus({ month: 1 }))).toBe("TITLE");
    expect(getDisplayTitle(event, end.plus({ month: 1 }))).toBe("TITLE");
  });
});
