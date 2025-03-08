import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "~/client/firebaseApp.js";
import type { CrontabHandler } from "../../core/crontab.js";
import { notifyDayDutyPerGroup } from "./notify_dayduty_per_group.js";

/**
 * 日直の通知
 */
export const notifyDayDuty: CrontabHandler = async (timestamp) => {
  const firestore = getFirestore(firebaseApp);

  const groupsSnapshot = await firestore.collection("groups").get();
  const groups = groupsSnapshot.docs.map((doc) => ({
    id: doc.id,
  }));

  await Promise.all(
    groups.map((group) => notifyDayDutyPerGroup(group, timestamp)),
  );
};
