import type { UserRecord } from "firebase-admin/auth";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { type LoginResult, login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";
import { fetchGoogleCalendarEvents } from "../../services/google_calendar_service.js";

vi.mock("../../services/google_calendar_service.js", () => ({
  fetchGoogleCalendarEvents: vi.fn(),
}));

const mockFetchGoogleCalendarEvents = vi.mocked(fetchGoogleCalendarEvents);

describe("ClassesController", () => {
  describe("GET /api/v1/groups/:groupId/classes", () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      mockFetchGoogleCalendarEvents.mockResolvedValue({ items: [] });

      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      const groupRef = firestore.collection("groups").doc("test_group_1");
      await groupRef.set({
        name: "Test Group",
        classes_calendar_id: "test-calendar-id",
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

    it("授業一覧を取得できること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/classes?from=2024-01-01T00:00:00Z&to=2024-01-31T23:59:59Z",
        {
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            Accept: "application/json",
          },
        },
      );

      const body = await response.json();

      expect(response.status).toBe(200);
      expect(body).toEqual({
        items: [],
      });
    });

    describe("グループが存在しない場合", () => {
      it("404エラーになること", async () => {
        const response = await app.request(
          "/api/v1/groups/non_existent_group/classes?from=2024-01-01T00:00:00Z&to=2024-01-31T23:59:59Z",
          {
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              Accept: "application/json",
            },
          },
        );

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
        const response = await app.request(
          "/api/v1/groups/test_group_1/classes?from=2024-01-01T00:00:00Z&to=2024-01-31T23:59:59Z",
          {
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              Accept: "application/json",
            },
          },
        );

        expect(response.status).toBe(403);
      });
    });

    describe("認証情報がない場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request(
          "/api/v1/groups/test_group_1/classes?from=2024-01-01T00:00:00Z&to=2024-01-31T23:59:59Z",
          {
            headers: {
              Accept: "application/json",
            },
          },
        );

        expect(response.status).toBe(401);
      });
    });

    describe("認証情報が不正な場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request(
          "/api/v1/groups/test_group_1/classes?from=2024-01-01T00:00:00Z&to=2024-01-31T23:59:59Z",
          {
            headers: {
              Authorization: "Bearer invalid_token",
              Accept: "application/json",
            },
          },
        );

        expect(response.status).toBe(401);
      });
    });

    describe("クエリパラメータが不正な場合", () => {
      describe("日付フォーマットが不正な場合", () => {
        it("400エラーになること", async () => {
          const response = await app.request(
            "/api/v1/groups/test_group_1/classes?from=invalid-date&to=2024-01-31T23:59:59Z",
            {
              headers: {
                Authorization: `Bearer ${loginResult.idToken}`,
                Accept: "application/json",
              },
            },
          );

          expect(response.status).toBe(400);
        });
      });

      describe("必須パラメータが不足している場合", () => {
        it("400エラーになること", async () => {
          const response = await app.request(
            "/api/v1/groups/test_group_1/classes?from=2024-01-01T00:00:00Z",
            {
              headers: {
                Authorization: `Bearer ${loginResult.idToken}`,
                Accept: "application/json",
              },
            },
          );

          expect(response.status).toBe(400);
        });
      });
    });

    describe("グループにカレンダーIDが設定されていない場合", () => {
      beforeEach(async () => {
        const groupRef = firestore
          .collection("groups")
          .doc("test_group_without_calendar");
        await groupRef.set({
          name: "Test Group Without Calendar",
          events_calendar_id: "events_calendar_id",
          dayduty_start_date: "2000-01-01",
          slack_event_channel_id: "slack_event_channel_id",
          weather_point: { lat: 0, lon: 0 },
        });

        const userJoinedGroupsRef = await firestore
          .collection("user_joined_groups")
          .add({
            user_id: "test_user_1",
            group_id: "test_group_without_calendar",
          });

        return async () => {
          await groupRef.delete();
          await userJoinedGroupsRef.delete();
        };
      });

      it("500エラーになること", async () => {
        const response = await app.request(
          "/api/v1/groups/test_group_without_calendar/classes?from=2024-01-01T00:00:00Z&to=2024-01-31T23:59:59Z",
          {
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              Accept: "application/json",
            },
          },
        );

        expect(response.status).toBe(500);
      });
    });
  });
});
