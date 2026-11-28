import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it } from "vitest";

import { clearBindings, grantGroup } from "../../../tests/helpers/bindings.js";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";

afterEach(clearBindings);

describe("Dayduty Controller", () => {
  let user: UserRecord;
  let loginResult: LoginResult;

  beforeEach(async () => {
    user = await auth.createUser({ uid: "test_user_1" });
    loginResult = await login(user);

    await firestore
      .collection("groups")
      .doc("test_group_1")
      .set({
        name: "Test Group",
        dayduty_start_date: "2025-01-01",
        classes_calendar_id: "",
        events_calendar_id: "",
        slack_event_channel_id: "",
        weather_point: { lat: 0, lon: 0 },
      });

    await grantGroup(user.uid, "test_group_1");

    await firestore.collection("classmates").doc("student_1").set({
      group_id: "test_group_1",
      role: "student",
      stuNo: 1,
      name: "Test Student",
      email: "student@example.com",
      slackUserId: "student1",
    });

    return async () => {
      await auth.deleteUser(user.uid);
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

  describe("GET /:groupId/dayduty", () => {
    it("認証なしでは401が返されること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/dayduty",
        {
          method: "GET",
        },
      );

      expect(response.status).toBe(401);
    });

    describe("グループが存在しない場合", () => {
      it("404が返されること", async () => {
        const response = await app.request(
          "/api/v1/groups/non_existent_group/dayduty",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
            },
          },
        );

        expect(response.status).toBe(404);
      });
    });

    describe("グループに参加していない場合", () => {
      it("グループがあることを明かさず、404が返されること", async () => {
        const unauthorizedUser = await auth.createUser({
          uid: `test_user_2_${Date.now()}`,
        });
        const unauthorizedLoginResult = await login(unauthorizedUser);

        const response = await app.request(
          "/api/v1/groups/test_group_1/dayduty",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${unauthorizedLoginResult.idToken}`,
            },
          },
        );

        expect(response.status).toBe(404);

        await auth.deleteUser(unauthorizedUser.uid);
      });
    });

    describe("メンバーを見る権限が無いロールの場合", () => {
      it("403が返されること", async () => {
        const viewer = await auth.createUser({
          uid: `test_viewer_${Date.now()}`,
        });
        const viewerLogin = await login(viewer);
        await grantGroup(viewer.uid, "test_group_1", "roles/group.viewer");

        const response = await app.request(
          "/api/v1/groups/test_group_1/dayduty",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${viewerLogin.idToken}`,
            },
          },
        );

        expect(response.status).toBe(403);

        await auth.deleteUser(viewer.uid);
      });
    });

    describe("開始日が設定されていない場合", () => {
      it("500が返されること", async () => {
        await firestore
          .collection("groups")
          .doc("test_group_2")
          .set({
            name: "Test Group No Start Date",
            classes_calendar_id: "",
            events_calendar_id: "",
            slack_event_channel_id: "",
            weather_point: { lat: 0, lon: 0 },
          });

        await grantGroup(user.uid, "test_group_2");

        const response = await app.request(
          "/api/v1/groups/test_group_2/dayduty",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
            },
          },
        );

        expect(response.status).toBe(500);

        await firestore.collection("groups").doc("test_group_2").delete();
      });
    });

    describe("学生が存在しない場合", () => {
      it("500が返されること", async () => {
        await firestore
          .collection("groups")
          .doc("test_group_3")
          .set({
            name: "Test Group No Students",
            dayduty_start_date: "2025-01-01",
            classes_calendar_id: "",
            events_calendar_id: "",
            slack_event_channel_id: "",
            weather_point: { lat: 0, lon: 0 },
          });

        await grantGroup(user.uid, "test_group_3");

        const response = await app.request(
          "/api/v1/groups/test_group_3/dayduty",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
            },
          },
        );

        expect(response.status).toBe(500);

        await firestore.collection("groups").doc("test_group_3").delete();
      });
    });

    describe("その日の日直がいない場合", () => {
      it("500が返されること", async () => {
        const rule = await firestore
          .collection("groups")
          .doc("test_group_1")
          .collection("dayduty_rules")
          .add({ member: "student_1", weekdays: [1, 2, 3, 4, 5, 6, 7] });

        const response = await app.request(
          "/api/v1/groups/test_group_1/dayduty",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
            },
          },
        );

        expect(response.status).toBe(500);

        await rule.delete();
      });
    });

    describe("不正な日付フォーマットの場合", () => {
      it("400が返されること", async () => {
        const response = await app.request(
          "/api/v1/groups/test_group_1/dayduty?date=invalid-date",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
            },
          },
        );

        expect(response.status).toBe(400);
      });
    });

    describe("日付を指定した場合", () => {
      it("指定した日の日直情報が取得できること", async () => {
        const response = await app.request(
          "/api/v1/groups/test_group_1/dayduty?date=2025-01-01T00:00:00%2B09:00",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
            },
          },
        );

        expect(response.status).toBe(200);
        const json = await response.json();
        expect(json).toEqual({
          name: "Test Student",
          members: [{ id: "student_1", name: "Test Student" }],
        });
      });
    });

    describe("日付を省略した場合", () => {
      it("今日の日直情報が取得できること", async () => {
        const response = await app.request(
          "/api/v1/groups/test_group_1/dayduty",
          {
            method: "GET",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
            },
          },
        );

        expect(response.status).toBe(200);
        const json = await response.json();
        expect(json).toEqual({
          name: "Test Student",
          members: [{ id: "student_1", name: "Test Student" }],
        });
      });
    });
  });
});
