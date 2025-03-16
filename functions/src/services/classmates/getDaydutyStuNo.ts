import { type Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/identity";
import { DateTime } from "luxon";
import { firebaseApp } from "~/client/firebaseApp.js";

/**
 * 入力された日時の日直の出席番号を取得する
 */
export const getDaydutyStuNo = async (
  groupId: string,
  date: DateTime,
): Promise<number> => {
  const firestore = getFirestore(firebaseApp);

  const groupSnapshot = await firestore.collection("groups").doc(groupId).get();
  const group = groupSnapshot.data();
  if (!group) {
    throw new HttpsError("invalid-argument", "Group not found");
  }

  // 日直制度の開始日
  const startDateEnv = group.dayduty_start_date as Timestamp;
  if (!startDateEnv) {
    throw new Error("Can not read DAYDUTY_START_DATE");
  }

  const zoneOffset = 9 * 60 * 60 * 1000;
  const startDate = DateTime.fromMillis(startDateEnv.toMillis() - zoneOffset, {
    zone: "Asia/Tokyo",
  });

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

  const stuNo = (elapseDays % classmateCount) + 1;

  return stuNo;
};
