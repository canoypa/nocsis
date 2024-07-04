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

  const targetChannelId = process.env.SLACK_EVENT_CHANNEL_ID;
  if (!targetChannelId) {
    throw new Error("Can not read SLACK_EVENT_CHANNEL_ID");
  }

  // 今日の範囲を取得
  const from = timestamp.startOf("day");
  const to = timestamp.plus({ day: 1 }).startOf("day");

  // 今日のイベントを取得する
  const todaySnapshot = await fetchCalendar(calendarId, {
    timeMin: from,
    timeMax: to,
    singleEvents: true,
    orderBy: "startTime",
  });
  if (!todaySnapshot.items) {
    // イベントがない場合は空の配列になるので、ありえないハズ
    throw new Error("items is not defined");
  }

  // カウントダウンイベントを取得する
  const countdownSnapshot = await fetchCountdownEvents();
  const countdownSnapshotFiltered =
    countdownSnapshot.items?.filter((e) => isCountdownTarget(e, timestamp)) ??
    [];

  // 内部用の形式に変換
  const events = parseEvents(todaySnapshot.items);
  const countdownEvents = parseEvents(countdownSnapshotFiltered);

  // イベントがない場合、終了
  if (events.length === 0 && countdownEvents.length === 0) {
    return;
  }

  // os通知に表示される装飾なしの簡易的な内容
  const eventTitles = events.map((e) => getDisplayTitle(e, from)).join(", ");

  // 通知処理
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
