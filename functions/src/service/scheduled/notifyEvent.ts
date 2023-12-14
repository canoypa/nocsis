import { ChatPostMessageArguments } from "@slack/web-api";
import { slackClient } from "../../client/slackClient";
import { fetchCalendar } from "../../core/calendar";
import { getDisplayTitle } from "../../core/calendar/get_display_title";
import { parseEvents } from "../../core/calendar/parseEvents";
import { eventsToSlackBlock } from "../../core/calendar/slack_block";
import { CrontabHandler } from "../../core/crontab";

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

  const snapshot = await fetchCalendar(calendarId, {
    timeMin: from,
    timeMax: to,
    singleEvents: true,
    orderBy: "startTime",
  });
  if (!snapshot.items) {
    throw new Error("items is not defined");
  }

  const events = parseEvents(snapshot.items);

  if (events.length === 0) {
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
    username: "今日のイベント",
    icon_emoji: ":date:",
    text: eventTitles,
    blocks: eventsToSlackBlock(events, from),
    unfurl_links: false,
    unfurl_media: false,
  };
  slackClient.chat.postMessage(options);
};
export default notifyEvent;
