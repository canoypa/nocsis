import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "../../client/firebaseApp";

/**
 * 登録されているクラスメイトの数を返す
 */
export const getStudentCount = async (): Promise<number> => {
  const firestore = getFirestore(firebaseApp);

  const snapshot = await firestore.doc("docCount/classmates").get();
  const data = snapshot.data();

  if (!data) {
    throw new Error("classmatesCount is not found");
  }

  return data.student;
};
