import {
  type ChatPostMessageArguments,
  WebClient as SlackWebClient,
} from "@slack/web-api";
import { getFirestore } from "firebase-admin/firestore";
import type { DateTime } from "luxon";
import { firebaseApp } from "~/client/firebaseApp.js";
import { fetchSecret } from "~/services/fetch_secret.js";
import type { CrontabHandler } from "../../core/crontab.js";
import { getDayduty } from "../../core/dayduty/getDayduty.js";
import { getTeacher } from "../../services/classmates/getTeacher.js";

type Group = {
  id: string;
};

const notifyDayDutyPerGroup = async (group: Group, timestamp: DateTime) => {
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

/**
 * 日直の通知
 */
const notifyDayDuty: CrontabHandler = async (timestamp) => {
  const firestore = getFirestore(firebaseApp);

  const groupsSnapshot = await firestore.collection("groups").get();
  const groups = groupsSnapshot.docs.map((doc) => ({
    id: doc.id,
  }));

  await Promise.all(
    groups.map((group) => notifyDayDutyPerGroup(group, timestamp)),
  );
};
export default notifyDayDuty;
