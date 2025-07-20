import { DateTime } from "luxon";
import { firestore } from "../clients/firebase.js";

/**
 * 指定された日時の日直の出席番号を取得する
 */
export const getDaydutyStuNo = async (
  groupId: string,
  date: DateTime,
): Promise<number> => {
  const groupSnapshot = await firestore.collection("groups").doc(groupId).get();
  const group = groupSnapshot.data();

  if (!group) {
    throw new Error("Group not found");
  }

  // 日直制度の開始日
  const startDateEnv = group.dayduty_start_date;
  if (!startDateEnv) {
    throw new Error("dayduty_start_date is not set");
  }

  const startDate = DateTime.fromISO(startDateEnv, { zone: "Asia/Tokyo" });

  const elapseDays = Math.floor(
    date.setZone("asia/tokyo").diff(startDate).as("days"),
  );

  const classmateCountSnapshot = await firestore
    .collection("classmates")
    .where("group_id", "==", groupId)
    .where("role", "==", "student")
    .count()
    .get();
  const classmateCount = classmateCountSnapshot.data().count;

  if (classmateCount === 0) {
    throw new Error("No students found in group");
  }

  const stuNo = (elapseDays % classmateCount) + 1;

  return stuNo;
};
