import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "../../client/firebaseApp.js";
import type { Teacher } from "../../types/classmates.js";

/**
 * 教師を取得する
 */
export const getTeacher = async (groupId: string): Promise<Teacher[]> => {
  const firestore = getFirestore(firebaseApp);

  const ref = firestore.collection("classmates");
  const snapshot = await ref
    .where("group_id", "==", groupId)
    .where("role", "==", "teacher")
    .get();

  return snapshot.docs.map((doc) => doc.data()) as Teacher[];
};
