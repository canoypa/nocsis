import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "~/client/firebaseApp.js";
import type { CrontabHandler } from "../../core/crontab.js";
import { notifyEventPerGroup } from "./notify_event_per_group.js";

/**
 * イベントの通知
 */
export const notifyEvent: CrontabHandler = async (timestamp) => {
  const firestore = getFirestore(firebaseApp);

  const groupsSnapshot = await firestore.collection("groups").get();
  const groups = groupsSnapshot.docs.map((doc) => ({
    id: doc.id,
    events_calendar_id: doc.get("events_calendar_id"),
    slack_event_channel_id: doc.get("slack_event_channel_id"),
  }));

  await Promise.allSettled(
    groups.map((group) => notifyEventPerGroup(group, timestamp)),
  );
};
