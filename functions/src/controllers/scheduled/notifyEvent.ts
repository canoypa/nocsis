import {
  type ChatPostMessageArguments,
  WebClient as SlackWebClient,
} from "@slack/web-api";
import { getFirestore } from "firebase-admin/firestore";
import type { DateTime } from "luxon";
import { firebaseApp } from "~/client/firebaseApp.js";
import { fetchSecret } from "~/services/fetch_secret.js";
import { fetchCalendar } from "../../core/calendar.js";
import { getDisplayTitle } from "../../core/calendar/get_display_title.js";
import { parseEvents } from "../../core/calendar/parseEvents.js";
import { eventsToSlackBlock } from "../../core/calendar/slack_block.js";
import type { CrontabHandler } from "../../core/crontab.js";
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
const notifyEventPerGroup = async (group: Group, timestamp: DateTime) => {
  const slackToken = await fetchSecret(`group_${group.id}-slack_token`);
  const slackClient = new SlackWebClient(slackToken);

  const calendarId = group.events_calendar_id;
  const targetChannelId = group.slack_event_channel_id;

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

const notifyEvent: CrontabHandler = async (timestamp) => {
  const firestore = getFirestore(firebaseApp);

  const groupsSnapshot = await firestore.collection("groups").get();
  const groups = groupsSnapshot.docs.map((doc) => ({
    id: doc.id,
    events_calendar_id: doc.get("events_calendar_id"),
    slack_event_channel_id: doc.get("slack_event_channel_id"),
  }));

  await Promise.all(
    groups.map((group) => notifyEventPerGroup(group, timestamp)),
  );
};

export default notifyEvent;
