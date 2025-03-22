import {
  type ChatPostMessageArguments,
  WebClient as SlackWebClient,
} from "@slack/web-api";
import type { DateTime } from "luxon";
import { fetchSecret } from "~/services/fetch_secret.js";
import { getDayduty } from "../../core/dayduty/getDayduty.js";
import { getTeacher } from "../classmates/getTeacher.js";

type Group = {
  id: string;
};

/**
 * 日直の通知
 */
export const notifyDayDutyPerGroup = async (
  group: Group,
  timestamp: DateTime,
) => {
  const slackToken = await fetchSecret(`group_${group.id}-slack_token`);
  const slackClient = new SlackWebClient(slackToken);

  const dayduty = await getDayduty(group.id, timestamp);
  const teacher = await getTeacher(group.id);

  const sendTargets = [
    dayduty.slackUserId,
    ...teacher.map((v) => v.slackUserId),
  ];

  for (const slackUserId of sendTargets) {
    const options: ChatPostMessageArguments = {
      channel: slackUserId,
      text: `今日の日直は、${dayduty.lastName}${dayduty.firstName}さんです。`,
      icon_emoji: ":bust_in_silhouette:",
      username: "今日の日直",
      // blocks: [],
    };
    slackClient.chat.postMessage(options);
  }
};
