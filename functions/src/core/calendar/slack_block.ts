import {
  Block,
  ContextBlock,
  DividerBlock,
  ImageElement,
  KnownBlock,
  MrkdwnElement,
  PlainTextElement,
  SectionBlock,
} from "@slack/web-api";
import { DateTime } from "luxon";
import { CalendarEvent } from "../../models/event";

export const eventsToSlackBlock = (events: CalendarEvent[], date: DateTime) => {
  const result: (KnownBlock | Block)[] = [];

  events.forEach((e, i, a) => {
    const title: SectionBlock = {
      type: "section",
      text: {
        type: "mrkdwn",
        text: `*${e.getDisplayTitle(date)}*`,
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

    if (e.getDisplayTimeRange(date)) {
      const time: MrkdwnElement = {
        type: "mrkdwn",
        text: `:clock3: ${e.getDisplayTimeRange(date)}`,
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

  // footer
  const dayFormat = date.toFormat("M月d日");
  const divider: DividerBlock = { type: "divider" };
  const footer: ContextBlock = {
    type: "context",
    elements: [{ type: "mrkdwn", text: `${dayFormat}のイベント` }],
  };
  result.push(divider, footer);

  return result;
};
