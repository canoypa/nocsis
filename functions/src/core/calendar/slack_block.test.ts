import { DateTime } from "luxon";
import { describe, expect, test } from "vitest";

import type { CalendarEvent } from "../../types/calendar.js";
import { eventsToSlackBlock } from "./slack_block.js";

const today = DateTime.fromObject({ year: 2024, month: 4, day: 1 });

const event = (props: Partial<CalendarEvent>): CalendarEvent => ({
  startAt: today.set({ hour: 10 }),
  endAt: today.set({ hour: 11 }),
  title: "朝会",
  description: "",
  location: "",
  isAllDay: false,
  ...props,
});

describe("eventsToSlackBlock", () => {
  test("イベントが無ければ何も出さない", () => {
    expect(eventsToSlackBlock([], [], today)).toEqual([]);
  });

  test("当日のイベントと今後のイベントを、区切りを挟んで並べる", () => {
    const blocks = eventsToSlackBlock(
      [
        event({ description: "体育館に集合", location: "体育館" }),
        event({ title: "委員会" }),
      ],
      [
        event({
          title: "終業式",
          startAt: today.plus({ days: 3 }),
          endAt: today.plus({ days: 4 }),
          isAllDay: true,
        }),
      ],
      today,
    );

    expect(blocks.map((block) => block.type)).toEqual([
      "header",
      "section",
      "section",
      "context",
      "divider",
      "section",
      "context",
      "divider",
      "header",
      "section",
    ]);
    expect(blocks[2]).toMatchObject({ text: { text: "体育館に集合" } });
    expect(blocks[3]).toMatchObject({
      elements: [
        { text: ":clock3: 10:00 ~ 11:00" },
        { text: ":round_pushpin: <https://map.google.com?q=体育館|体育館>" },
      ],
    });
    expect(blocks[9]).toMatchObject({
      text: { text: "*終業式* まであと 3 日！" },
    });
  });

  test("今後のイベントの説明と場所も出す", () => {
    const blocks = eventsToSlackBlock(
      [],
      [
        event({
          title: "避難訓練",
          startAt: today.plus({ days: 1, hours: 10 }),
          endAt: today.plus({ days: 1, hours: 11 }),
          description: "上履きのまま",
          location: "校庭",
        }),
        event({
          title: "終業式",
          startAt: today.plus({ days: 2 }),
          endAt: today.plus({ days: 3 }),
          isAllDay: true,
        }),
      ],
      today,
    );

    expect(blocks.map((block) => block.type)).toEqual([
      "header",
      "section",
      "section",
      "context",
      "divider",
      "section",
    ]);
    expect(blocks[3]).toMatchObject({
      elements: [
        {},
        { text: ":round_pushpin: <https://map.google.com?q=校庭|校庭>" },
      ],
    });
  });
});
