import * as slackModule from "@slack/web-api";
import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { DateTime } from "luxon";
import {
  type MockedObject,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import * as fetchSecretModule from "../fetch_secret.js";
import { notifyDayDutyPerGroup } from "./notify_dayduty_per_group.js";

describe("notifyDayDutyPerGroup", () => {
  const group = {
    id: "group_1",
    dayduty_start_date: Timestamp.fromDate(new Date("2025-01-01")),
  };

  const student = {
    group_id: "group_1",
    role: "student",
    stuNo: 1,
    slackUserId: "slack_user_student_1",
    firstName: "2",
    lastName: "テストユーザー",
  };

  const teacher = {
    group_id: "group_1",
    role: "teacher",
    slackUserId: "slack_user_teacher_1",
    firstName: "2",
    lastName: "テストユーザー",
  };

  beforeEach(async () => {
    const firestore = getFirestore(firebaseApp);

    await firestore.collection("groups").doc(group.id).set(group);
    await firestore.collection("classmates").add(student);
    await firestore.collection("classmates").add(teacher);
  });

  it("通知されること", async () => {
    vi.spyOn(fetchSecretModule, "fetchSecret").mockResolvedValue(
      "dummy_slack_token",
    );

    const postMessage = vi.fn();
    const mockedSlackWebClient = {
      chat: { postMessage },
    } as unknown as MockedObject<slackModule.WebClient>;
    vi.spyOn(slackModule, "WebClient").mockImplementation(
      () => mockedSlackWebClient,
    );

    const date = DateTime.local(2025, 1, 1);
    await notifyDayDutyPerGroup(group, date);

    expect(postMessage).toBeCalledTimes(2);
    expect(postMessage).toBeCalledWith({
      channel: student.slackUserId,
      text: `今日の日直は、${student.lastName}${student.firstName}さんです。`,
      icon_emoji: ":bust_in_silhouette:",
      username: "今日の日直",
    });
    expect(postMessage).toBeCalledWith({
      channel: teacher.slackUserId,
      text: `今日の日直は、${student.lastName}${student.firstName}さんです。`,
      icon_emoji: ":bust_in_silhouette:",
      username: "今日の日直",
    });
  });
});
