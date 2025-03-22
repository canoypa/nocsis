import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "../../client/firebaseApp.js";

/**
 * 登録されているクラスメイトの数を返す
 * @deprecated count関数で簡単に取れるようになった: https://firebase.google.com/docs/firestore/query-data/aggregation-queries#use_the_count_aggregation
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
