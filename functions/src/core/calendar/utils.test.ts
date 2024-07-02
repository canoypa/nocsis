import { DateTime } from "luxon";
import { describe, expect, it } from "vitest";
import type { CalendarEvent } from "~/types/calendar.js";
import { isAllDay, isMultipleDays } from "./utils.js";

const EXAMPLE_ONE_DAY_EVENT: CalendarEvent = {
  isAllDay: false,
  startAt: DateTime.fromObject({ year: 2024, month: 1, day: 1, hour: 10 }),
  endAt: DateTime.fromObject({ year: 2024, month: 1, day: 1, hour: 10 }),
  title: "Example Event",
  description: "Example Description",
  location: "Example Location",
};

const EXAMPLE_MULTIPLE_DAYS_EVENT: CalendarEvent = {
  isAllDay: false,
  startAt: DateTime.fromObject({ year: 2024, month: 1, day: 1, hour: 10 }),
  endAt: DateTime.fromObject({ year: 2024, month: 1, day: 2, hour: 10 }),
  title: "Example Event",
  description: "Example Description",
  location: "Example Location",
};

const EXAMPLE_ALL_DAY_ONE_DAY_EVENT: CalendarEvent = {
  isAllDay: true,
  startAt: DateTime.fromObject({ year: 2024, month: 1, day: 1 }),
  endAt: DateTime.fromObject({ year: 2024, month: 1, day: 2 }), // 全日イベントの endAt は翌日の 0:00
  title: "Example Event",
  description: "Example Description",
  location: "Example Location",
};

const EXAMPLE_ALL_DAY_MULTIPLE_DAYS_EVENT: CalendarEvent = {
  isAllDay: true,
  startAt: DateTime.fromObject({ year: 2024, month: 1, day: 1 }),
  endAt: DateTime.fromObject({ year: 2024, month: 1, day: 3 }), // 全日イベントの endAt は翌日の 0:00
  title: "Example Event",
  description: "Example Description",
  location: "Example Location",
};

describe("isAllDay", () => {
  it("should return true if the event is all day", () => {
    expect(isAllDay(EXAMPLE_ALL_DAY_ONE_DAY_EVENT)).toBe(true);
    expect(isAllDay(EXAMPLE_ALL_DAY_MULTIPLE_DAYS_EVENT)).toBe(true);
  });

  it("should return false if the event is not all day", () => {
    expect(isAllDay(EXAMPLE_ONE_DAY_EVENT)).toBe(false);
    expect(isAllDay(EXAMPLE_MULTIPLE_DAYS_EVENT)).toBe(false);
  });
});

describe("isMultipleDays", () => {
  it("should return true if the event spans multiple days", () => {
    expect(isMultipleDays(EXAMPLE_MULTIPLE_DAYS_EVENT)).toBe(true);
    expect(isMultipleDays(EXAMPLE_ALL_DAY_MULTIPLE_DAYS_EVENT)).toBe(true);
  });

  it("should return false if the event does not span multiple days", () => {
    expect(isMultipleDays(EXAMPLE_ONE_DAY_EVENT)).toBe(false);
    expect(isMultipleDays(EXAMPLE_ALL_DAY_ONE_DAY_EVENT)).toBe(false);
  });
});
