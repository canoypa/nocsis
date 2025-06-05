import { inspect } from "node:util";
import type { UserRecord } from "firebase-admin/auth";
import { beforeEach, describe, expect, it } from "vitest";
import { type LoginResult, login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";

describe("GroupController", () => {
  describe("GET /api/v1/groups/:id", async () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      const groupRef = firestore.collection("groups").doc("test_group_1");

      await groupRef.set({
        name: "Test Group",
        classes_calendar_id: "classes_calendar_id",
        events_calendar_id: "events_calendar_id",
        dayduty_start_date: "2000-01-01",
        slack_event_channel_id: "slack_event_channel_id",
        weather_point: { lat: 0, lon: 0 },
      });

      const userJoinedGroupsRef = await firestore
        .collection("user_joined_groups")
        .add({
          user_id: "test_user_1",
          group_id: "test_group_1",
        });

      return async () => {
        await auth.deleteUser("test_user_1");
        await groupRef.delete();
        await userJoinedGroupsRef.delete();
      };
    });

    it("グループ情報を取得できること", async () => {
      const response = await app.request("/api/v1/groups/test_group_1", {
        headers: {
          Authorization: `Bearer ${loginResult.idToken}`,
          Accept: "application/json",
        },
      });
      const body = await response.json();

      expect(response.status).toBe(200);
      expect(body).toEqual({
        id: "test_group_1",
        name: "Test Group",
        classes_calendar_id: "classes_calendar_id",
        events_calendar_id: "events_calendar_id",
        dayduty_start_date: "2000-01-01",
        slack_event_channel_id: "slack_event_channel_id",
        weather_point: { lat: 0, lon: 0 },
      });
    });

    describe("グループが存在しない場合", async () => {
      it("404エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_2", {
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(404);
      });
    });

    describe("ユーザーがグループに参加していない場合", () => {
      let user: UserRecord;
      let loginResult: LoginResult;

      beforeEach(async () => {
        user = await auth.createUser({ uid: "test_user_not_in_group_1" });
        loginResult = await login(user);

        return async () => {
          await auth.deleteUser(user.uid);
        };
      });

      it("403エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(403);
      });
    });

    describe("認証情報がない場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          headers: {
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(401);
      });
    });

    describe("認証情報が不正な場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          headers: {
            Authorization: "Bearer invalid_token",
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(401);
      });
    });
  });

  describe.todo("POST /api/v1/groups/:id", () => {});

  describe("PATCH /api/v1/groups/:id", () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      const groupRef = firestore.collection("groups").doc("test_group_1");

      await groupRef.set({
        name: "Test Group",
        classes_calendar_id: "classes_calendar_id",
        events_calendar_id: "events_calendar_id",
        dayduty_start_date: "2000-01-01",
        slack_event_channel_id: "slack_event_channel_id",
        weather_point: { lat: 0, lon: 0 },
      });

      const userJoinedGroupsRef = await firestore
        .collection("user_joined_groups")
        .add({
          user_id: "test_user_1",
          group_id: "test_group_1",
        });

      return async () => {
        await auth.deleteUser("test_user_1");
        await groupRef.delete();
        await userJoinedGroupsRef.delete();
      };
    });

    it("更新できること", async () => {
      const response = await app.request("/api/v1/groups/test_group_1", {
        method: "PATCH",
        headers: {
          Authorization: `Bearer ${loginResult.idToken}`,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify({
          name: "Updated Test Name",
          classes_calendar_id: "updated_classes_calendar_id",
          events_calendar_id: "updated_events_calendar_id",
          dayduty_start_date: "2099-12-31",
          slack_event_channel_id: "updated_slack_event_channel_id",
          weather_point: { lat: 99, lon: 99 },
        }),
      });
      const body = await response.json();

      expect(response.status).toBe(200);
      expect(body).toEqual({
        id: "test_group_1",
        name: "Updated Test Name",
        classes_calendar_id: "updated_classes_calendar_id",
        events_calendar_id: "updated_events_calendar_id",
        dayduty_start_date: "2099-12-31",
        slack_event_channel_id: "updated_slack_event_channel_id",
        weather_point: { lat: 99, lon: 99 },
      });
    });

    describe("一部のデータを更新する場合", () => {
      it("更新できること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
          }),
        });
        const body = await response.json();

        expect(response.status).toBe(200);
        expect(body).toEqual({
          id: "test_group_1",
          name: "Updated Test Name",
          classes_calendar_id: "classes_calendar_id",
          events_calendar_id: "events_calendar_id",
          dayduty_start_date: "2000-01-01",
          slack_event_channel_id: "slack_event_channel_id",
          weather_point: { lat: 0, lon: 0 },
        });
      });
    });

    describe("グループが存在しない場合", async () => {
      it("404エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_2", {
          method: "PATCH",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
            classes_calendar_id: "updated_classes_calendar_id",
            events_calendar_id: "updated_events_calendar_id",
            dayduty_start_date: "2099-12-31",
            slack_event_channel_id: "updated_slack_event_channel_id",
            weather_point: { lat: 99, lon: 99 },
          }),
        });

        expect(response.status).toBe(404);
      });
    });

    describe("データが不正な場合", () => {
      describe("データが空の場合", async () => {
        it("400エラーになること", async () => {
          const response = await app.request("/api/v1/groups/test_group_1", {
            method: "PATCH",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              "Content-Type": "application/json",
              Accept: "application/json",
            },
            body: JSON.stringify({}),
          });

          expect(response.status).toBe(400);
        });
      });

      describe("データの型が異なる場合", () => {
        it("400エラーになること", async () => {
          const response = await app.request("/api/v1/groups/test_group_1", {
            method: "PATCH",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              "Content-Type": "application/json",
              Accept: "application/json",
            },
            body: JSON.stringify("invalid data"),
          });

          expect(response.status).toBe(400);
        });
      });

      describe("フィールドのデータ型が異なる場合", () => {
        it("400エラーになること", async () => {
          const response = await app.request("/api/v1/groups/test_group_1", {
            method: "PATCH",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              "Content-Type": "application/json",
              Accept: "application/json",
            },
            body: JSON.stringify({
              name: 123,
            }),
          });

          expect(response.status).toBe(400);
        });
      });

      describe("存在しないフィールドが含まれる場合", () => {
        it("400エラーになること", async () => {
          const response = await app.request("/api/v1/groups/test_group_1", {
            method: "PATCH",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              "Content-Type": "application/json",
              Accept: "application/json",
            },
            body: JSON.stringify({
              invalid_field: "invalid_field",
            }),
          });

          expect(response.status).toBe(400);
        });
      });
    });

    describe("ユーザーがグループに参加していない場合", () => {
      let user: UserRecord;
      let loginResult: LoginResult;

      beforeEach(async () => {
        user = await auth.createUser({ uid: "test_user_not_in_group_1" });
        loginResult = await login(user);

        return async () => {
          await auth.deleteUser(user.uid);
        };
      });

      it("403エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
            classes_calendar_id: "updated_classes_calendar_id",
            events_calendar_id: "updated_events_calendar_id",
            dayduty_start_date: "2099-12-31",
            slack_event_channel_id: "updated_slack_event_channel_id",
            weather_point: { lat: 99, lon: 99 },
          }),
        });

        expect(response.status).toBe(403);
      });
    });

    describe("認証情報がない場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
            classes_calendar_id: "updated_classes_calendar_id",
            events_calendar_id: "updated_events_calendar_id",
            dayduty_start_date: "2099-12-31",
            slack_event_channel_id: "updated_slack_event_channel_id",
            weather_point: { lat: 99, lon: 99 },
          }),
        });

        expect(response.status).toBe(401);
      });
    });

    describe("認証情報が不正な場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            Authorization: "Bearer invalid_token",
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
            classes_calendar_id: "updated_classes_calendar_id",
            events_calendar_id: "updated_events_calendar_id",
            dayduty_start_date: "2099-12-31",
            slack_event_channel_id: "updated_slack_event_channel_id",
            weather_point: { lat: 99, lon: 99 },
          }),
        });

        expect(response.status).toBe(401);
      });
    });
  });

  describe.todo("DELETE /api/v1/groups/:id", () => {});
});
