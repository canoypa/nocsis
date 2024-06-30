import type { calendar_v3 } from "@googleapis/calendar";
import { DateTime } from "luxon";
import { describe, expect, it } from "vitest";
import {
  isCountdownTarget,
  matchCountdownPattern,
  removeCountdownPattern,
} from "./countdown_event.js";

const EXAMPLE_START_DATE = "2024-06-10T00:00:00+09:00";
const EXAMPLE_END_DATE = "2024-06-20T00:00:00+09:00";

const EXAMPLE_EVERYDAY: calendar_v3.Schema$Event = {
  eventType: "default",
  summary: "EVENT#1",
  description: "countdown",
  start: {
    dateTime: EXAMPLE_START_DATE,
    timeZone: "Asia/Tokyo",
  },
  end: {
    dateTime: EXAMPLE_END_DATE,
    timeZone: "Asia/Tokyo",
  },
};

const EXAMPLE_BEFORE_10DAYS: calendar_v3.Schema$Event = {
  eventType: "default",
  summary: "EVENT#2",
  description: "countdown.before=10day",
  start: {
    dateTime: EXAMPLE_START_DATE,
    timeZone: "Asia/Tokyo",
  },
  end: {
    dateTime: EXAMPLE_END_DATE,
    timeZone: "Asia/Tokyo",
  },
};

const EXAMPLE_BEFORE_1MONTH: calendar_v3.Schema$Event = {
  eventType: "default",
  summary: "EVENT#2",
  description: "countdown.before=1month",
  start: {
    dateTime: EXAMPLE_START_DATE,
    timeZone: "Asia/Tokyo",
  },
  end: {
    dateTime: EXAMPLE_END_DATE,
    timeZone: "Asia/Tokyo",
  },
};

const EXAMPLE_INVALID: calendar_v3.Schema$Event = {
  eventType: "default",
  summary: "EVENT#2",
  description: "countdown.before=123invalid",
  start: {
    dateTime: EXAMPLE_START_DATE,
    timeZone: "Asia/Tokyo",
  },
  end: {
    dateTime: EXAMPLE_END_DATE,
    timeZone: "Asia/Tokyo",
  },
};

const EXAMPLE_NOT_COUNTDOWN: calendar_v3.Schema$Event = {
  eventType: "default",
  summary: "EVENT#3",
  description: "not countdown",
  start: {
    dateTime: EXAMPLE_START_DATE,
    timeZone: "Asia/Tokyo",
  },
  end: {
    dateTime: EXAMPLE_END_DATE,
    timeZone: "Asia/Tokyo",
  },
};

describe("matchCountdownPattern", () => {
  it("should return true if the description matches the pattern", () => {
    expect(matchCountdownPattern("countdown")).toBeTruthy();
    expect(matchCountdownPattern("countdown.before=10day")).toBeTruthy();
    expect(matchCountdownPattern("countdown.before=1month")).toBeTruthy();
    expect(
      matchCountdownPattern("countdown.before=1month\nfoo bar"),
    ).toBeTruthy();
  });

  it("should return false if the description does not match the pattern", () => {
    expect(matchCountdownPattern("")).toBe(null);
    expect(matchCountdownPattern("countdown.before=-10day")).toBe(null);
    expect(matchCountdownPattern("countdown.before=123INVALID")).toBe(null);
    expect(matchCountdownPattern("not countdown")).toBe(null);
    expect(matchCountdownPattern("countdown EXTRA TEXT")).toBe(null);
  });
});

describe("isCountdownTarget", () => {
  const date = DateTime.fromObject({ year: 2024, month: 6, day: 5 });

  it("should return true if the event is a countdown event", () => {
    expect(isCountdownTarget(EXAMPLE_EVERYDAY, date)).toBe(true);
    expect(isCountdownTarget(EXAMPLE_BEFORE_10DAYS, date)).toBe(true);
    expect(isCountdownTarget(EXAMPLE_BEFORE_1MONTH, date)).toBe(true);
  });

  it("should return false if the event is not a countdown event", () => {
    expect(isCountdownTarget(EXAMPLE_NOT_COUNTDOWN, date)).toBe(false);
    expect(isCountdownTarget(EXAMPLE_INVALID, date)).toBe(false);
  });

  describe("when the event has a countdown option", () => {
    it("should return true if the current date is between the countdown start date and the event start date", () => {
      const before10Days = DateTime.fromObject({
        year: 2024,
        month: 5,
        day: 31,
      });
      expect(isCountdownTarget(EXAMPLE_BEFORE_10DAYS, before10Days)).toBe(true);

      const before1Day = DateTime.fromObject({ year: 2024, month: 6, day: 9 });
      expect(isCountdownTarget(EXAMPLE_BEFORE_10DAYS, before1Day)).toBe(true);
    });

    it("should return false if the current date is before the countdown start date", () => {
      const before1Month = DateTime.fromObject({ year: 2024, month: 5 });
      expect(isCountdownTarget(EXAMPLE_BEFORE_10DAYS, before1Month)).toBe(
        false,
      );

      const before11Day = DateTime.fromObject({
        year: 2024,
        month: 5,
        day: 30,
      });
      expect(isCountdownTarget(EXAMPLE_BEFORE_10DAYS, before11Day)).toBe(false);
    });

    it("should return false if the current date is after the event start date", () => {
      const sameDay = DateTime.fromObject({ year: 2024, month: 6, day: 10 });
      expect(isCountdownTarget(EXAMPLE_BEFORE_10DAYS, sameDay)).toBe(false);

      const after1Day = DateTime.fromObject({ year: 2024, month: 6, day: 11 });
      expect(isCountdownTarget(EXAMPLE_BEFORE_10DAYS, after1Day)).toBe(false);
    });
  });
});

describe("removeCountdownPattern", () => {
  it("should remove the countdown pattern from the text", () => {
    expect(removeCountdownPattern("countdown")).toBe("");
    expect(removeCountdownPattern("countdown.before=10day")).toBe("");
    expect(removeCountdownPattern("countdown.before=1month")).toBe("");
    expect(removeCountdownPattern("countdown.before=1month\nfoo bar")).toBe(
      "foo bar",
    );
  });

  it("should return the original text if the text does not match the pattern", () => {
    expect(removeCountdownPattern("")).toBe("");
    expect(removeCountdownPattern("countdown EXTRA TEXT")).toBe(
      "countdown EXTRA TEXT",
    );
  });
});
