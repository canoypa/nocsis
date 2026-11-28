import { DateTime } from "luxon";

import { firestore } from "../clients/firebase.js";
import { AppConfig } from "../config/app_config.js";

/** 開始日や生徒がないなど、日直を決められないグループ */
export class DaydutyNotConfiguredError extends Error {}

/**
 * 指定された日時の日直の出席番号を取得する
 */
export const getDaydutyStuNo = async (
  groupId: string,
  date: DateTime<true>,
): Promise<number> => {
  const groupSnapshot = await firestore.collection("groups").doc(groupId).get();
  const group = groupSnapshot.data();

  if (!group) {
    throw new Error("Group not found");
  }

  // 日直制度の開始日
  const startDateEnv = group.dayduty_start_date;
  if (!startDateEnv) {
    throw new DaydutyNotConfiguredError("dayduty_start_date is not set");
  }

  const startDate = DateTime.fromISO(startDateEnv, {
    zone: AppConfig.TIMEZONE,
  });

  if (!startDate.isValid) {
    throw new DaydutyNotConfiguredError(
      "日直開始日のフォーマットが正しくありません",
    );
  }

  const elapseDays = Math.floor(
    date.setZone(AppConfig.TIMEZONE).diff(startDate).as("days"),
  );

  const classmateCountSnapshot = await firestore
    .collection("classmates")
    .where("group_id", "==", groupId)
    .where("role", "==", "student")
    .count()
    .get();
  const classmateCount = classmateCountSnapshot.data().count;

  if (classmateCount === 0) {
    throw new DaydutyNotConfiguredError("No students found in group");
  }

  const stuNo = (elapseDays % classmateCount) + 1;

  return stuNo;
};

export type DaydutyMember = { id: string; name: string };

/**
 * その日の日直。画面と通知はこれだけを読む。当たる出席番号の人がいなければ空
 */
export const getDaydutyOfDay = async (
  groupId: string,
  date: DateTime<true>,
): Promise<DaydutyMember[]> => {
  const stuNo = await getDaydutyStuNo(groupId, date);
  const snapshot = await firestore
    .collection("classmates")
    .where("group_id", "==", groupId)
    .where("stuNo", "==", stuNo)
    .select("name")
    .get();
  return snapshot.docs
    .slice(0, 1)
    .map((doc) => ({ id: doc.id, name: doc.get("name") as string }));
};
