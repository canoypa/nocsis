import { getFirestore } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { getStudentCount } from "./getStudentCount.js";

describe("getStudentCount", () => {
  const data = {
    student: 30,
  };

  beforeEach(async () => {
    const db = getFirestore(firebaseApp);
    const collection = db.collection("/docCount");

    await collection.doc("classmates").set(data);
  });

  it("正しい値を取得できること", async () => {
    await expect(getStudentCount()).resolves.toBe(30);
  });
});
