import type { UserRecord } from "firebase-admin/auth";
import { beforeEach, describe, expect, it } from "vitest";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";

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

    await firestore.collection("user_joined_groups").add({
      user_id: user.uid,
      group_id: "test_group_1",
      created_at: new Date(),
    });

    await firestore.collection("classmates").add({
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

      const userJoinedGroupsSnapshot = await firestore
        .collection("user_joined_groups")
        .where("user_id", "==", user.uid)
        .where("group_id", "==", "test_group_1")
        .get();

      const classmatesSnapshot = await firestore
        .collection("classmates")
        .where("group_id", "==", "test_group_1")
        .get();

      const batch = firestore.batch();
      for (const doc of userJoinedGroupsSnapshot.docs) {
        batch.delete(doc.ref);
      }
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
      it("403が返されること", async () => {
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

        expect(response.status).toBe(403);

        await auth.deleteUser(unauthorizedUser.uid);
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

        await firestore.collection("user_joined_groups").add({
          user_id: user.uid,
          group_id: "test_group_2",
          created_at: new Date(),
        });

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
        const userJoinedGroupsSnapshot = await firestore
          .collection("user_joined_groups")
          .where("user_id", "==", user.uid)
          .where("group_id", "==", "test_group_2")
          .get();

        const batch = firestore.batch();
        for (const doc of userJoinedGroupsSnapshot.docs) {
          batch.delete(doc.ref);
        }
        await batch.commit();
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

        await firestore.collection("user_joined_groups").add({
          user_id: user.uid,
          group_id: "test_group_3",
          created_at: new Date(),
        });

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
        const userJoinedGroupsSnapshot = await firestore
          .collection("user_joined_groups")
          .where("user_id", "==", user.uid)
          .where("group_id", "==", "test_group_3")
          .get();

        const batch = firestore.batch();
        for (const doc of userJoinedGroupsSnapshot.docs) {
          batch.delete(doc.ref);
        }
        await batch.commit();
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
        expect(json).toHaveProperty("stuNo", 1);
        expect(json).toHaveProperty("name", "Test Student");
        expect(json).toHaveProperty("role", "student");
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
        expect(json).toHaveProperty("stuNo");
        expect(json).toHaveProperty("name");
        expect(json).toHaveProperty("role", "student");
      });
    });
  });
});
