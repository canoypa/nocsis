import { DateTime } from "luxon";
import { describe, expect, test } from "vitest";
import { CalendarEvent } from "../../types/calendar.js";
import { getDisplayTitle } from "./get_display_title.js";

const d = DateTime.fromISO;
const c = (
  startAt: DateTime,
  endAt: DateTime,
  isAllDay?: boolean,
): CalendarEvent => ({
  startAt: startAt,
  endAt: endAt,
  title: "TITLE",
  description: "",
  location: "",
  isAllDay: isAllDay ?? false,
});

describe("getDisplayTitle", () => {
  test("通常イベント", () => {
    const start = d("2024-01-01T09:00:00.000+09:00");
    const end = d("2024-01-02T09:00:00.000+09:00");
    const event = c(start, end);

    expect(getDisplayTitle(event, d("2024-01-01T08:00:00.000+09:00"))).toBe(
      "TITLE (Day 1/2)",
    );
    expect(getDisplayTitle(event, d("2024-01-01T09:00:00.000+09:00"))).toBe(
      "TITLE (Day 1/2)",
    );
    expect(getDisplayTitle(event, d("2024-01-01T10:00:00.000+09:00"))).toBe(
      "TITLE (Day 1/2)",
    );

    // 範囲外
    expect(getDisplayTitle(event, start.minus({ month: 1 }))).toBe("TITLE");
    expect(getDisplayTitle(event, end.plus({ month: 1 }))).toBe("TITLE");
  });

  test("終日イベント", () => {
    const start = d("2024-01-01T00:00:00.000+09:00");
    const end = d("2024-01-03T00:00:00.000+09:00");
    const event = c(start, end, true);

    expect(getDisplayTitle(event, d("2024-01-01T00:00:00.000+09:00"))).toBe(
      "TITLE (Day 1/2)",
    );
    expect(getDisplayTitle(event, d("2024-01-02T00:00:00.000+09:00"))).toBe(
      "TITLE (Day 2/2)",
    );

    // 範囲外
    expect(getDisplayTitle(event, start.minus({ month: 1 }))).toBe("TITLE");
    expect(getDisplayTitle(event, end.plus({ month: 1 }))).toBe("TITLE");
  });
});
