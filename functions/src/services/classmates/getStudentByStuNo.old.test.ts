import { getFirestore } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import type { Student } from "~/types/classmates.js";
import { getStudentByStuNo } from "./getStudentByStuNo.old.js";

describe("getStudentByStuNo", () => {
  const data: Student = {
    role: "student",
    group_id: "group_1",
    stuNo: 1,
    name: "Foo Bar",
    slackUserId: "foobar",
  };

  beforeEach(async () => {
    const db = getFirestore(firebaseApp);
    const collection = db.collection("/classmates");

    await collection.add(data);
  });

  it("指定した出席番号の生徒を取得できる", async () => {
    await expect(getStudentByStuNo(1)).resolves.toEqual([data]);
  });

  it("該当するレコードがない場合、エラーが発生する", async () => {
    await expect(getStudentByStuNo(2)).rejects.toThrowError(
      "Classmate not found: 2",
    );
  });

  describe("複数指定する場合", () => {
    const data2: Student = {
      role: "student",
      group_id: "group_2",
      stuNo: 2,
      name: "Baz Qux",
      slackUserId: "bazqux",
    };

    beforeEach(async () => {
      const db = getFirestore(firebaseApp);
      const collection = db.collection("/classmates");

      await collection.add(data2);
    });

    it("指定した出席番号の生徒を取得できる", async () => {
      await expect(getStudentByStuNo(1, 2)).resolves.toEqual([data, data2]);
    });

    it("該当するレコードがない場合、エラーが発生する", async () => {
      await expect(getStudentByStuNo(3, 4)).rejects.toThrowError(
        "Classmate not found: 3,4",
      );
    });
  });
});
