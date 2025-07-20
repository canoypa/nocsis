import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";

describe("UserController", () => {
  describe("GET /api/v1/users/me/groups", () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      await firestore
        .collection("groups")
        .doc("test_group_1")
        .set({
          name: "Test Group 1",
          classes_calendar_id: "",
          events_calendar_id: "",
          dayduty_start_date: "",
          slack_event_channel_id: "",
          weather_point: { lat: 35.0, lon: 139.0 },
        });

      await firestore
        .collection("groups")
        .doc("test_group_2")
        .set({
          name: "Test Group 2",
          classes_calendar_id: "",
          events_calendar_id: "",
          dayduty_start_date: "",
          slack_event_channel_id: "",
          weather_point: { lat: 35.0, lon: 139.0 },
        });

      await firestore
        .collection("user_joined_groups")
        .doc("test_user_joined_group_1")
        .set({
          user_id: user.uid,
          group_id: "test_group_1",
          group_name: "Test Group 1",
        });

      await firestore
        .collection("user_joined_groups")
        .doc("test_user_joined_group_2")
        .set({
          user_id: user.uid,
          group_id: "test_group_2",
          group_name: "Test Group 2",
        });
    });

    afterEach(async () => {
      await auth.deleteUser(user.uid);
      await firestore
        .collection("user_joined_groups")
        .doc("test_user_joined_group_1")
        .delete();
      await firestore
        .collection("user_joined_groups")
        .doc("test_user_joined_group_2")
        .delete();
      await firestore.collection("groups").doc("test_group_1").delete();
      await firestore.collection("groups").doc("test_group_2").delete();
    });

    it("参加しているグループ一覧を取得できる", async () => {
      const res = await app.request("/api/v1/users/me/groups", {
        headers: {
          Authorization: `Bearer ${loginResult.idToken}`,
          Accept: "application/json",
        },
      });

      const body = await res.json();

      expect(res.status).toBe(200);
      expect(body).toEqual({
        items: expect.arrayContaining([
          {
            id: "test_group_1",
            name: "Test Group 1",
            classes_calendar_id: "",
            events_calendar_id: "",
            dayduty_start_date: "",
            slack_event_channel_id: "",
            weather_point: { lat: 35.0, lon: 139.0 },
          },
          {
            id: "test_group_2",
            name: "Test Group 2",
            classes_calendar_id: "",
            events_calendar_id: "",
            dayduty_start_date: "",
            slack_event_channel_id: "",
            weather_point: { lat: 35.0, lon: 139.0 },
          },
        ]),
      });
      expect(body.items).toHaveLength(2);
    });

    describe("認証情報がない場合", () => {
      it("401 Unauthorized を返す", async () => {
        const res = await app.request("/api/v1/users/me/groups", {
          headers: { Accept: "application/json" },
        });

        expect(res.status).toBe(401);
      });
    });

    describe("認証情報が不正な場合", () => {
      it("401エラーになること", async () => {
        const res = await app.request("/api/v1/users/me/groups", {
          headers: {
            Authorization: "Bearer invalid_token",
            Accept: "application/json",
          },
        });

        expect(res.status).toBe(401);
      });
    });
  });
});
