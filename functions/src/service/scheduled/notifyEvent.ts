import type { ChatPostMessageArguments } from "@slack/web-api";
import { slackClient } from "../../client/slackClient.js";
import { fetchCalendar } from "../../core/calendar.js";
import { getDisplayTitle } from "../../core/calendar/get_display_title.js";
import { parseEvents } from "../../core/calendar/parseEvents.js";
import { eventsToSlackBlock } from "../../core/calendar/slack_block.js";
import type { CrontabHandler } from "../../core/crontab.js";
import { fetchCountdownEvents, isCountdownTarget } from "./countdown_event.js";

/**
 * イベントの通知
 */
const notifyEvent: CrontabHandler = async (timestamp) => {
  const calendarId = process.env.EVENTS_CALENDAR_ID;
  if (!calendarId) {
    throw new Error("EVENTS_CALENDAR_ID is not defined");
  }

  const from = timestamp.startOf("day");
  const to = timestamp.plus({ day: 1 }).startOf("day");

  const todaySnapshot = await fetchCalendar(calendarId, {
    timeMin: from,
    timeMax: to,
    singleEvents: true,
    orderBy: "startTime",
  });
  if (!todaySnapshot.items) {
    throw new Error("items is not defined");
  }

  const countdownSnapshot = await fetchCountdownEvents();
  const countdownSnapshotFiltered =
    countdownSnapshot.items?.filter((e) => isCountdownTarget(e, timestamp)) ??
    [];

  const events = parseEvents(todaySnapshot.items);
  const countdownEvents = parseEvents(countdownSnapshotFiltered);

  if (events.length === 0 && countdownEvents.length === 0) {
    // イベントがない場合、終了
    return;
  }

  // 通知処理
  const targetChannelId = process.env.SLACK_EVENT_CHANNEL_ID;
  if (!targetChannelId) {
    throw new Error("Can not read SLACK_EVENT_CHANNEL_ID");
  }

  const eventTitles = events.map((e) => getDisplayTitle(e, from)).join(", ");

  const options: ChatPostMessageArguments = {
    channel: targetChannelId,
    username: "イベントBot",
    icon_emoji: ":date:",
    text: eventTitles,
    blocks: eventsToSlackBlock(events, countdownEvents, from),
    unfurl_links: false,
    unfurl_media: false,
  };
  slackClient.chat.postMessage(options);
};
export default notifyEvent;
