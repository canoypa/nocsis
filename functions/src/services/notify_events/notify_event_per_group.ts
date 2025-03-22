import assert from "node:assert";
import {
  type ChatPostMessageArguments,
  WebClient as SlackWebClient,
} from "@slack/web-api";
import type { DateTime } from "luxon";
import { fetchSecret } from "~/services/fetch_secret.js";
import { fetchCalendar } from "../../core/calendar.js";
import { getDisplayTitle } from "../../core/calendar/get_display_title.js";
import { parseEvents } from "../../core/calendar/parseEvents.js";
import { eventsToSlackBlock } from "../../core/calendar/slack_block.js";
import {
  fetchCountdownEvents,
  isCountdownTarget,
} from "../../core/events/countdown_event.js";

type Group = {
  id: string;
  events_calendar_id: string;
  slack_event_channel_id: string;
};

/**
 * イベントの通知
 */
export const notifyEventPerGroup = async (
  group: Group,
  timestamp: DateTime,
) => {
  const slackToken = await fetchSecret(`group_${group.id}-slack_token`);
  const slackClient = new SlackWebClient(slackToken);

  const calendarId = group.events_calendar_id;
  const targetChannelId = group.slack_event_channel_id;
  assert(group.events_calendar_id, "events_calendar_id is not defined");
  assert(group.slack_event_channel_id, "slack_event_channel_id is not defined");

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
  const countdownSnapshot = await fetchCountdownEvents(calendarId);
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
