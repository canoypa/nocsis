import { getFirestore } from "firebase-admin/firestore";
import { DateTime } from "luxon";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import type { Student, Teacher } from "~/types/classmates.js";
import { getDaydutyStuNo } from "./getDaydutyStuNo.js";

describe("getDaydutyStuNo", () => {
  const group = {
    dayduty_start_date: "2025-01-01",
  };

  const student: Student = {
    role: "student",
    group_id: "group_1",
    stuNo: 1,
    name: "テストユーザー 1",
    slackUserId: "slack_user_student_1",
  };

  const teacher: Teacher = {
    role: "teacher",
    group_id: "group_1",
    slackUserId: "slack_user_teacher_1",
  };

  beforeEach(async () => {
    const db = getFirestore(firebaseApp);

    const groupCollection = db.collection("groups");
    await groupCollection.doc("group_1").set(group);

    const studentCollection = db.collection("classmates");
    await studentCollection.add(student);
    await studentCollection.add(student);
    await studentCollection.add(student);
    await studentCollection.add(student);

    await studentCollection.add(teacher);
  });

  it("指定した日時の日直の出席番号を取得できる", async () => {
    await expect(
      getDaydutyStuNo("group_1", DateTime.local(2025, 1, 1)),
    ).to.resolves.toBe(1);

    await expect(
      getDaydutyStuNo("group_1", DateTime.local(2025, 1, 2)),
    ).to.resolves.toBe(2);

    await expect(
      getDaydutyStuNo("group_1", DateTime.local(2025, 1, 4)),
    ).to.resolves.toBe(4);

    await expect(
      getDaydutyStuNo("group_1", DateTime.local(2025, 1, 5)),
    ).to.resolves.toBe(1);
  });
});
