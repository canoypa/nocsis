import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "../../client/firebaseApp.js";
import { Teacher } from "../../types/classmates.js";

/**
 * 先生を取得する
 */
export const getTeacher = async (): Promise<Teacher[]> => {
  const firestore = getFirestore(firebaseApp);

  const ref = firestore.collection("classmates");
  const snapshot = await ref.where("role", "==", "teacher").get();

  return snapshot.docs.map((doc) => doc.data()) as Teacher[];
};
