import type { ChatPostMessageArguments } from "@slack/web-api";
import { slackClient } from "../../client/slackClient.js";
import type { CrontabHandler } from "../../core/crontab.js";
import { getDayduty } from "../../core/dayduty/getDayduty.old.js";
import { getTeacher } from "../../services/classmates/getTeacher.old.js";

/**
 * 日直の通知
 */
const notifyDayDuty: CrontabHandler = async (timestamp) => {
  const dayduty = await getDayduty(timestamp);
  const teacher = await getTeacher();

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
export default notifyDayDuty;
