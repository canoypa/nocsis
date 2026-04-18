import { getFirestore } from "firebase-admin/firestore";
import { DateTime } from "luxon";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import type { Student, Teacher } from "~/types/classmates.js";
import * as fetchSecretModule from "../fetch_secret.js";
import { notifyDayDutyPerGroup } from "./notify_dayduty_per_group.js";

const { mockPostMessage } = vi.hoisted(() => ({ mockPostMessage: vi.fn() }));

vi.mock("@slack/web-api", () => ({
  WebClient: class {
    chat = { postMessage: mockPostMessage };
  },
}));

describe("notifyDayDutyPerGroup", () => {
  const group = {
    id: "group_1",
    dayduty_start_date: "2025-01-01",
  };

  const student: Student = {
    group_id: "group_1",
    role: "student",
    stuNo: 1,
    slackUserId: "slack_user_student_1",
    name: "テストユーザー 2",
  };

  const teacher: Teacher = {
    group_id: "group_1",
    role: "teacher",
    slackUserId: "slack_user_teacher_1",
  };

  beforeEach(async () => {
    mockPostMessage.mockResolvedValue({});

    const firestore = getFirestore(firebaseApp);

    await firestore.collection("groups").doc(group.id).set(group);
    await firestore.collection("classmates").add(student);
    await firestore.collection("classmates").add(teacher);
  });

  afterEach(() => {
    vi.resetAllMocks();
  });

  it("通知されること", async () => {
    vi.spyOn(fetchSecretModule, "fetchSecret").mockResolvedValue(
      "dummy_slack_token",
    );

    const date = DateTime.local(2025, 1, 1);
    await notifyDayDutyPerGroup(group, date);

    expect(mockPostMessage).toHaveBeenCalledTimes(2);
    expect(mockPostMessage).toHaveBeenCalledWith({
      channel: student.slackUserId,
      text: `今日の日直は、${student.name}さんです。`,
      icon_emoji: ":bust_in_silhouette:",
      username: "今日の日直",
    });
    expect(mockPostMessage).toHaveBeenCalledWith({
      channel: teacher.slackUserId,
      text: `今日の日直は、${student.name}さんです。`,
      icon_emoji: ":bust_in_silhouette:",
      username: "今日の日直",
    });
  });
});
