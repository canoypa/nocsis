import { getFirestore } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import type { Student } from "~/types/classmates.js";
import { getStudentByStuNo } from "./getStudentByStuNo.js";

describe("getStudentByStuNo", () => {
  const data1: Student = {
    role: "student",
    group_id: "group_1",
    stuNo: 1,
    name: "Foo Bar",
    slackUserId: "foobar",
  };
  const data2: Student = {
    role: "student",
    group_id: "group_2",
    stuNo: 1,
    name: "Foo Bar",
    slackUserId: "foobar",
  };

  beforeEach(async () => {
    const db = getFirestore(firebaseApp);
    const collection = db.collection("/classmates");

    await collection.add(data1);
    await collection.add(data2);
  });

  it("指定した出席番号の生徒を取得できる", async () => {
    await expect(getStudentByStuNo("group_1", 1)).resolves.toEqual([data1]);
  });

  it("該当するレコードがない場合、エラーが発生する", async () => {
    await expect(getStudentByStuNo("group_1", 2)).rejects.toThrowError(
      "Classmate not found: 2",
    );
  });

  describe("複数指定する場合", () => {
    const data3: Student = {
      role: "student",
      group_id: "group_1",
      stuNo: 2,
      name: "Baz Qux",
      slackUserId: "bazqux",
    };

    beforeEach(async () => {
      const db = getFirestore(firebaseApp);
      const collection = db.collection("/classmates");

      await collection.add(data3);
    });

    it("指定した出席番号の生徒を取得できる", async () => {
      await expect(getStudentByStuNo("group_1", 1, 2)).resolves.toEqual([
        data1,
        data3,
      ]);
    });

    it("該当するレコードがない場合、エラーが発生する", async () => {
      await expect(getStudentByStuNo("group_1", 3, 4)).rejects.toThrowError(
        "Classmate not found: 3,4",
      );
    });
  });
});
