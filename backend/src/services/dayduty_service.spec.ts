import { DateTime } from "luxon";
import { beforeEach, describe, expect, it } from "vitest";
import { firestore } from "../clients/firebase.js";
import { getDaydutyStuNo } from "./dayduty_service.js";

describe("getDaydutyStuNo", () => {
  beforeEach(async () => {
    await firestore.collection("groups").doc("test_group_1").set({
      name: "Test Group",
      dayduty_start_date: "2025-01-01",
    });

    const classmates = [
      {
        group_id: "test_group_1",
        role: "student",
        stuNo: 1,
        name: "Test Student 1",
        email: "student1@example.com",
        slackUserId: "student1",
      },
      {
        group_id: "test_group_1",
        role: "student",
        stuNo: 2,
        name: "Test Student 2",
        email: "student2@example.com",
        slackUserId: "student2",
      },
      {
        group_id: "test_group_1",
        role: "student",
        stuNo: 3,
        name: "Test Student 3",
        email: "student3@example.com",
        slackUserId: "student3",
      },
      {
        group_id: "test_group_1",
        role: "student",
        stuNo: 4,
        name: "Test Student 4",
        email: "student4@example.com",
        slackUserId: "student4",
      },
    ];

    const batch = firestore.batch();
    for (const classmate of classmates) {
      const ref = firestore.collection("classmates").doc();
      batch.set(ref, classmate);
    }
    await batch.commit();

    return async () => {
      await firestore.collection("groups").doc("test_group_1").delete();

      const classmatesSnapshot = await firestore
        .collection("classmates")
        .where("group_id", "==", "test_group_1")
        .get();

      const batch = firestore.batch();
      for (const doc of classmatesSnapshot.docs) {
        batch.delete(doc.ref);
      }
      await batch.commit();
    };
  });

  it("開始日（2025-01-01）は出席番号1が返されること", async () => {
    const result = await getDaydutyStuNo(
      "test_group_1",
      DateTime.local(2025, 1, 1) as DateTime<true>,
    );
    expect(result).toBe(1);
  });

  it("開始日の翌日（2025-01-02）は出席番号2が返されること", async () => {
    const result = await getDaydutyStuNo(
      "test_group_1",
      DateTime.local(2025, 1, 2) as DateTime<true>,
    );
    expect(result).toBe(2);
  });

  it("開始日の4日後（2025-01-05）は出席番号1が返されること（4人なので周回）", async () => {
    const result = await getDaydutyStuNo(
      "test_group_1",
      DateTime.local(2025, 1, 5) as DateTime<true>,
    );
    expect(result).toBe(1);
  });

  describe("教師ロールが混在している場合", () => {
    beforeEach(async () => {
      // 教師を追加
      await firestore.collection("classmates").add({
        group_id: "test_group_1",
        role: "teacher",
        stuNo: 99,
        name: "Teacher",
        email: "teacher@example.com",
        slackUserId: "teacher",
      });

      return async () => {
        const teacherSnapshot = await firestore
          .collection("classmates")
          .where("group_id", "==", "test_group_1")
          .where("role", "==", "teacher")
          .get();

        const batch = firestore.batch();
        for (const doc of teacherSnapshot.docs) {
          batch.delete(doc.ref);
        }
        await batch.commit();
      };
    });

    it("学生のみがカウントされること", async () => {
      // 学生が4人なので、5日目（4 % 4 + 1 = 1）は出席番号1が返される
      const result = await getDaydutyStuNo(
        "test_group_1",
        DateTime.local(2025, 1, 5) as DateTime<true>,
      );
      expect(result).toBe(1);
    });
  });

  describe("グループが存在しない場合", () => {
    it("エラーが発生すること", async () => {
      await expect(
        getDaydutyStuNo(
          "non_existent_group",
          DateTime.local(2025, 1, 1) as DateTime<true>,
        ),
      ).rejects.toThrow("Group not found");
    });
  });

  describe("dayduty_start_dateが設定されていない場合", () => {
    it("エラーが発生すること", async () => {
      await firestore.collection("groups").doc("test_group_no_start").set({
        name: "Test Group No Start",
      });

      await expect(
        getDaydutyStuNo(
          "test_group_no_start",
          DateTime.local(2025, 1, 1) as DateTime<true>,
        ),
      ).rejects.toThrow("dayduty_start_date is not set");

      await firestore.collection("groups").doc("test_group_no_start").delete();
    });
  });

  describe("学生が存在しない場合", () => {
    it("エラーが発生すること", async () => {
      await firestore.collection("groups").doc("test_group_no_students").set({
        name: "Test Group No Students",
        dayduty_start_date: "2025-01-01",
      });

      await expect(
        getDaydutyStuNo(
          "test_group_no_students",
          DateTime.local(2025, 1, 1) as DateTime<true>,
        ),
      ).rejects.toThrow("No students found in group");

      await firestore
        .collection("groups")
        .doc("test_group_no_students")
        .delete();
    });
  });
});
