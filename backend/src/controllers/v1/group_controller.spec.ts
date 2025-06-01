import { type UserRecord, getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { type LoginResult, login } from "../../../tests/helpers/users.js";
import { app } from "../../routes.js";

describe("GroupController", () => {
  describe("GET /v1/groups/:id", async () => {
    const auth = getAuth();
    const firestore = getFirestore();

    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      user = await auth.createUser({
        uid: "test",
      });

      loginResult = await login(user);

      await firestore
        .collection("groups")
        .doc("1234")
        .set({
          name: "Test Group",
          classes_calendar_id: "classes_calendar_id",
          events_calendar_id: "events_calendar_id",
          dayduty_start_date: "2000-01-01",
          slack_event_channel_id: "slack_event_channel_id",
          weather_point: { lat: 0, lon: 0 },
        });

      await firestore.collection("user_joined_groups").add({
        user_id: user.uid,
        group_id: "1234",
      });
    });

    afterEach(async () => {
      await auth.deleteUser(user.uid);
    });

    it("グループ情報を取得できること", async () => {
      const response = await app.request("/api/v1/groups/1234", {
        headers: {
          Authorization: `Bearer ${loginResult.idToken}`,
        },
      });
      const body = await response.json();

      expect(response.status).toBe(200);
      expect(body).toEqual({
        id: "1234",
        name: "Test Group",
        classes_calendar_id: "classes_calendar_id",
        events_calendar_id: "events_calendar_id",
        dayduty_start_date: "2000-01-01",
        slack_event_channel_id: "slack_event_channel_id",
        weather_point: {
          lat: 0,
          lon: 0,
        },
      });
    });

    describe("グループが存在しない場合", async () => {
      it("404エラーになること", async () => {
        const response = await app.request("/api/v1/groups/5678", {
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        });
        const body = await response.text();

        expect(response.status).toBe(404);
        expect(body).toBe("グループが見つかりません。");
      });
    });

    describe("ユーザーがグループに参加していない場合", () => {
      let user: UserRecord;
      let loginResult: LoginResult;

      beforeEach(async () => {
        user = await auth.createUser({
          uid: "user_not_in_group",
        });

        loginResult = await login(user);
      });

      afterEach(async () => {
        await auth.deleteUser(user.uid);
      });

      it("404エラーになること", async () => {
        const response = await app.request("/api/v1/groups/1234", {
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        });
        const body = await response.text();

        expect(response.status).toBe(404);
        expect(body).toBe("グループが見つかりません。");
      });
    });

    describe("認証情報がない場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/dummy");
        const body = await response.text();

        expect(response.status).toBe(401);
        expect(body).toBe("Unauthorized");
      });
    });

    describe("認証情報が不正な場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/1234", {
          headers: {
            Authorization: "Bearer invalid_token",
          },
        });
        const body = await response.text();
        expect(response.status).toBe(401);
        expect(body).toBe("Unauthorized");
      });
    });
  });

  describe.todo("POST /v1/groups", () => {});

  describe.todo("PUT /v1/groups/:id", () => {});

  describe.todo("DELETE /v1/groups/:id", () => {});
});
