import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "../../client/firebaseApp.js";
import type { Student } from "../../types/classmates.js";

/**
 * 入力された出席番号の生徒を取得する
 * @deprecated 複数クラスで使用できるようにする(#314)対応に伴ってgroupカラムが追加され、将来的に適切な値を返すことができなくなるため
 */
export const getStudentByStuNo = async (
  ...stuNos: [number, ...number[]]
): Promise<Student[]> => {
  const firestore = getFirestore(firebaseApp);

  const ref = firestore.collection("classmates");
  const snapshot = await ref
    .where("stuNo", "in", stuNos)
    .orderBy("stuNo")
    .get();

  // 入力された出席番号に対して、取得した生徒数が足りない場合エラー
  if (snapshot.size !== stuNos.length) {
    throw new Error(`Classmate not found: ${stuNos}`);
  }

  return snapshot.docs.map((doc) => doc.data()) as Student[];
};
