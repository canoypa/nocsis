import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "../../client/firebaseApp.js";
import type { Teacher } from "../../types/classmates.js";

/**
 * 先生を取得する
 * @deprecated 複数クラスで使用できるようにする(#314)対応に伴ってgroupカラムが追加され、将来的に適切な値を返すことができなくなるため
 */
export const getTeacher = async (): Promise<Teacher[]> => {
  const firestore = getFirestore(firebaseApp);

  const ref = firestore.collection("classmates");
  const snapshot = await ref.where("role", "==", "teacher").get();

  return snapshot.docs.map((doc) => doc.data()) as Teacher[];
};
