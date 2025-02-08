import type { calendar_v3 } from "@googleapis/calendar";
import { DateTime, Zone } from "luxon";
import { describe, expect, it } from "vitest";
import {
  isCountdownTarget,
  matchCountdownPattern,
  removeCountdownPattern,
} from "./countdown_event.js";

type MakeEventOptions = {
  summary?: string;
  description?: string;

  // e.g. "2024-06-10T00:00:00+09:00"
  startDateTime?: string;
  endDateTime?: string;

  // 全日イベントの場合はこっちで日付だけ
  // e.g. "2024-06-10"
  startDate?: string;
  endDate?: string;
};
const makeEvent = ({
  summary,
  description,
  ...options
}: MakeEventOptions): calendar_v3.Schema$Event => {
  return {
    summary: summary ?? "SUMMARY",
    description: description ?? "DESCRIPTION",
    start: {
      dateTime: options.startDateTime,
      date: options.startDate,
      timeZone: "Asia/Tokyo",
    },
    end: {
      dateTime: options.endDateTime,
      date: options.endDate,
      timeZone: "Asia/Tokyo",
    },
  };
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
  const before1Month = DateTime.fromISO("2024-05-15T00:00:00+09:00", {
    zone: "Asia/Tokyo",
  });
  const before1MonthAndDay = before1Month.minus({ millisecond: 1 });
  const before10Days = DateTime.fromISO("2024-06-05T00:00:00+09:00", {
    zone: "Asia/Tokyo",
  });
  const before11Days = before10Days.minus({ millisecond: 1 });
  const eventDay = DateTime.fromISO("2024-06-15T00:00:00+09:00", {
    zone: "Asia/Tokyo",
  });
  const beforeDay = eventDay.minus({ millisecond: 1 });

  describe("前日までカウントダウンの場合", () => {
    describe("全日イベントの場合", () => {
      const event = makeEvent({
        description: "countdown",
        startDate: "2024-06-15",
        endDate: "2024-06-16",
      });

      it("前日は対象である", () => {
        expect(isCountdownTarget(event, beforeDay)).toBeTruthy();
      });

      it("当日は対象でない", () => {
        expect(isCountdownTarget(event, eventDay)).toBeFalsy();
      });
    });

    describe("時間指定のイベントの場合", () => {
      const event = makeEvent({
        description: "countdown",
        startDateTime: "2024-06-15T10:00:00+09:00",
        endDateTime: "2024-06-15T12:00:00+09:00",
      });

      it("前日は対象である", () => {
        expect(isCountdownTarget(event, beforeDay)).toBeTruthy();
      });

      it("当日は対象でない", () => {
        expect(isCountdownTarget(event, eventDay)).toBeFalsy();
      });
    });
  });

  describe("10日前からカウントダウンの場合", () => {
    describe("全日イベントの場合", () => {
      const event = makeEvent({
        description: "countdown.before=10day",
        startDate: "2024-06-15",
        endDate: "2024-06-16",
      });

      it("11日前は対象でない", () => {
        expect(isCountdownTarget(event, before11Days)).toBeFalsy();
      });

      it("10日前は対象である", () => {
        expect(isCountdownTarget(event, before10Days)).toBeTruthy();
      });

      it("前日は対象である", () => {
        expect(isCountdownTarget(event, beforeDay)).toBeTruthy();
      });

      it("当日は対象でない", () => {
        expect(isCountdownTarget(event, eventDay)).toBeFalsy();
      });
    });

    describe("時間指定のイベントの場合", () => {
      const event = makeEvent({
        description: "countdown.before=10day",
        startDateTime: "2024-06-15T10:00:00+09:00",
        endDateTime: "2024-06-15T12:00:00+09:00",
      });

      it("11日前は対象でない", () => {
        expect(isCountdownTarget(event, before11Days)).toBeFalsy();
      });

      it("10日前は対象である", () => {
        expect(isCountdownTarget(event, before10Days)).toBeTruthy();
      });

      it("前日は対象である", () => {
        expect(isCountdownTarget(event, beforeDay)).toBeTruthy();
      });

      it("当日は対象でない", () => {
        expect(isCountdownTarget(event, eventDay)).toBeFalsy();
      });
    });
  });

  describe("1ヶ月前からカウントダウンの場合", () => {
    describe("全日イベントの場合", () => {
      const event = makeEvent({
        description: "countdown.before=1month",
        startDate: "2024-06-15",
        endDate: "2024-06-16",
      });

      it("1ヶ月と1日前は対象でない", () => {
        expect(isCountdownTarget(event, before1MonthAndDay)).toBeFalsy();
      });

      it("1ヶ月前は対象である", () => {
        expect(isCountdownTarget(event, before1Month)).toBeTruthy();
      });

      it("前日は対象である", () => {
        expect(isCountdownTarget(event, beforeDay)).toBeTruthy();
      });

      it("当日は対象でない", () => {
        expect(isCountdownTarget(event, eventDay)).toBeFalsy();
      });
    });

    describe("時間指定のイベントの場合", () => {
      const event = makeEvent({
        description: "countdown.before=1month",
        startDateTime: "2024-06-15T10:00:00+09:00",
        endDateTime: "2024-06-15T12:00:00+09:00",
      });

      it("1ヶ月と1日前は対象でない", () => {
        expect(isCountdownTarget(event, before1MonthAndDay)).toBeFalsy();
      });

      it("1ヶ月前は対象である", () => {
        expect(isCountdownTarget(event, before1Month)).toBeTruthy();
      });

      it("前日は対象である", () => {
        expect(isCountdownTarget(event, beforeDay)).toBeTruthy();
      });

      it("当日は対象でない", () => {
        expect(isCountdownTarget(event, eventDay)).toBeFalsy();
      });
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
