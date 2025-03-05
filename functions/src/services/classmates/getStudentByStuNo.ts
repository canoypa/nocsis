import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "../../client/firebaseApp.js";
import type { Student } from "../../types/classmates.js";

/**
 * 入力された出席番号の生徒を取得する
 */
export const getStudentByStuNo = async (
  groupId: string,
  ...stuNos: [number, ...number[]]
): Promise<Student[]> => {
  const firestore = getFirestore(firebaseApp);

  const ref = firestore.collection("classmates");
  const snapshot = await ref
    .where("group_id", "==", groupId)
    .where("stuNo", "in", stuNos)
    .orderBy("stuNo")
    .get();

  // 入力された出席番号に対して、取得した生徒数が足りない場合エラー
  if (snapshot.size !== stuNos.length) {
    throw new Error(`Classmate not found: ${stuNos}`);
  }

  return snapshot.docs.map((doc) => doc.data()) as Student[];
};
