import { WebClient } from "@slack/web-api";
import type { DateTime } from "luxon";

import { firestore } from "../clients/firebase.js";
import { AppConfig } from "../config/app_config.js";
import {
  DaydutyNotConfiguredError,
  getDaydutyOfDay,
} from "./dayduty_service.js";
import { fetchSecret } from "./secret_manager_service.js";

/** gRPC の NOT_FOUND。Secret がない */
const NOT_FOUND = 5;

/** Slack のトークンがなく、通知を送れないグループ */
class SlackNotConfiguredError extends Error {}

const slackToken = async (groupId: string) => {
  try {
    // トークンを入れ直したとき、古いトークンで送り続けないよう毎回読む
    return await fetchSecret(`group_${groupId}-slack_token`, { cache: false });
  } catch (err) {
    if ((err as { code?: unknown }).code === NOT_FOUND)
      throw new SlackNotConfiguredError("Slack のトークンがありません");
    throw err;
  }
};

/**
 * 今日の日直を、その人と先生に Slack で知らせる。日直がいない日は送らない
 *
 * 送れない宛先があっても、ほかの宛先には送ってから失敗にする
 */
export const notifyDayduty = async (
  groupId: string,
  now: DateTime<true>,
): Promise<void> => {
  const members = await getDaydutyOfDay(groupId, now);
  if (members.length === 0) return;

  const classmates = await firestore
    .collection("classmates")
    .where("group_id", "==", groupId)
    .get();
  const slackUserOf = (doc: FirebaseFirestore.DocumentSnapshot) => {
    const id = doc.get("slackUserId");
    return typeof id === "string" && id !== "" ? [id] : [];
  };
  const memberIds = new Set(members.map((m) => m.id));
  const recipients = new Set(
    classmates.docs
      .filter((doc) => memberIds.has(doc.id) || doc.get("role") === "teacher")
      .flatMap(slackUserOf),
  );

  // 呼び手の Scheduler と Hosting は 60 秒で切るので、Slack の再試行や rate limit の解除を待たない
  const slack = new WebClient(await slackToken(groupId), {
    retryConfig: { retries: 0 },
    rejectRateLimitedCalls: true,
    timeout: 10_000,
  });
  const names = members.map((m) => `${m.name}さん`).join("、");
  const results = await Promise.allSettled(
    [...recipients].map(async (channel) => {
      try {
        await slack.chat.postMessage({
          channel,
          text: `今日の日直は、${names}です。`,
          icon_emoji: ":bust_in_silhouette:",
          username: "今日の日直",
        });
      } catch (err) {
        console.error("日直の通知を送れませんでした", {
          group: groupId,
          slackUserId: channel,
          err,
        });
        throw err;
      }
    }),
  );
  if (results.some((result) => result.status === "rejected")) {
    throw new Error("日直の通知を送れなかった宛先があります");
  }
};

/**
 * 通知を止めていないすべてのグループに、今日の日直を知らせる。知らせられなかったグループの ID を返す
 */
export const notifyAllDayduty = async (
  now: DateTime<true>,
): Promise<string[]> => {
  const today = now.setZone(AppConfig.TIMEZONE);
  if (!today.isValid)
    throw new Error(`無効な日時です: ${today.invalidExplanation}`);
  const groups = await firestore.collection("groups").get();

  // 日直の開始日がないグループは、日直を使っていない
  const targets = groups.docs.filter(
    (group) =>
      group.get("dayduty_notification_enabled") !== false &&
      Boolean(group.get("dayduty_start_date")),
  );
  const results = await Promise.all(
    targets.map(async (group) => {
      try {
        await notifyDayduty(group.id, today);
        return [];
      } catch (err) {
        if (
          err instanceof DaydutyNotConfiguredError ||
          err instanceof SlackNotConfiguredError
        ) {
          console.warn("日直を知らせられないグループを飛ばしました", {
            group: group.id,
            reason: err.message,
          });
          return [];
        }
        console.error("日直の通知に失敗しました", { group: group.id, err });
        return [group.id];
      }
    }),
  );
  return results.flat();
};
