import { cloudEvent } from "@google-cloud/functions-framework";
import type {
  Block,
  ContextBlock,
  DividerBlock,
  HeaderBlock,
  ImageElement,
  KnownBlock,
  MrkdwnElement,
  PlainTextElement,
  SectionBlock,
} from "@slack/web-api";
import type { DateTime } from "luxon";
import type { CalendarEvent } from "../../types/calendar.js";
import { getDisplayTimeRange } from "./get_display_time_range.js";
import { getDisplayTitle } from "./get_display_title.js";

export const eventsToSlackBlock = (
  events: CalendarEvent[],
  countdownEvents: CalendarEvent[],
  date: DateTime,
) => {
  const result: (KnownBlock | Block)[] = [];

  // header
  const dayFormat = date.toFormat("M月d日");
  const header: HeaderBlock = {
    type: "header",
    text: { type: "plain_text", text: `${dayFormat}のイベント` },
  };
  result.push(header);

  events.forEach((e, i, a) => {
    const title: SectionBlock = {
      type: "section",
      text: {
        type: "mrkdwn",
        text: `*${getDisplayTitle(e, date)}*`,
      },
    };
    result.push(title);

    if (e.description) {
      const description: SectionBlock = {
        type: "section",
        text: {
          type: "mrkdwn",
          text: e.description,
        },
      };
      result.push(description);
    }

    // Contexts
    const contexts: (ImageElement | PlainTextElement | MrkdwnElement)[] = [];

    if (getDisplayTimeRange(e, date)) {
      const time: MrkdwnElement = {
        type: "mrkdwn",
        text: `:clock3: ${getDisplayTimeRange(e, date)}`,
      };
      contexts.push(time);
    }

    if (e.location) {
      const location: MrkdwnElement = {
        type: "mrkdwn",
        text: `:round_pushpin: <https://map.google.com?q=${e.location}|${e.location}>`,
      };
      contexts.push(location);
    }

    if (contexts.length > 0) {
      const context: ContextBlock = {
        type: "context",
        elements: contexts,
      };
      result.push(context);
    }

    // Divider
    if (i !== a.length - 1) {
      const divider: DividerBlock = { type: "divider" };
      result.push(divider);
    }
  });

  if (countdownEvents.length > 0) {
    // header
    const divider: DividerBlock = { type: "divider" };
    const header: HeaderBlock = {
      type: "header",
      text: { type: "plain_text", text: "今後のイベント" },
    };
    result.push(divider, header);

    countdownEvents.forEach((e, i, a) => {
      const diff = e.startAt.diff(date, "days").days;
      const title: SectionBlock = {
        type: "section",
        text: {
          type: "mrkdwn",
          text: `*${e.title}* まであと ${diff} 日！`,
        },
      };
      result.push(title);

      if (e.description) {
        const description: SectionBlock = {
          type: "section",
          text: {
            type: "mrkdwn",
            text: e.description,
          },
        };
        result.push(description);
      }

      // Contexts
      const contexts: (ImageElement | PlainTextElement | MrkdwnElement)[] = [];

      if (getDisplayTimeRange(e, date)) {
        const time: MrkdwnElement = {
          type: "mrkdwn",
          text: `:clock3: ${getDisplayTimeRange(e, date)}`,
        };
        contexts.push(time);
      }

      if (e.location) {
        const location: MrkdwnElement = {
          type: "mrkdwn",
          text: `:round_pushpin: <https://map.google.com?q=${e.location}|${e.location}>`,
        };
        contexts.push(location);
      }

      if (contexts.length > 0) {
        const context: ContextBlock = {
          type: "context",
          elements: contexts,
        };
        result.push(context);
      }

      // Divider
      if (i !== a.length - 1) {
        const divider: DividerBlock = { type: "divider" };
        result.push(divider);
      }
    });
  }

  return result;
};
