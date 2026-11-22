import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { clearBindings, grantGroup } from "../../../tests/helpers/bindings.js";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";
import { fetchGoogleCalendarEvents } from "../../services/google_calendar_service.js";

afterEach(clearBindings);

vi.mock("../../services/google_calendar_service.js", () => ({
  fetchGoogleCalendarEvents: vi.fn(),
}));

const mockFetchGoogleCalendarEvents = vi.mocked(fetchGoogleCalendarEvents);

describe("Events Controller", () => {
  let user: UserRecord;
  let loginResult: LoginResult;

  beforeEach(async () => {
    mockFetchGoogleCalendarEvents.mockResolvedValue({ items: [] });

    user = await auth.createUser({ uid: "test_user_1" });
    loginResult = await login(user);

    await firestore
      .collection("groups")
      .doc("test_group_1")
      .set({
        name: "Test Group",
        events_calendar_id: "test-calendar-id",
        classes_calendar_id: "",
        dayduty_start_date: "",
        slack_event_channel_id: "",
        weather_point: { lat: 0, lon: 0 },
      });

    await grantGroup(user.uid, "test_group_1");
  });

  afterEach(async () => {
    await auth.deleteUser(user.uid);
    await firestore.collection("groups").doc("test_group_1").delete();
  });

  describe("GET /:groupId/events", () => {
    it("認証が必要であること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&limit=10",
        {
          method: "GET",
        },
      );

      expect(response.status).toBe(401);
    });

    it("グループが存在しない場合は404が返されること", async () => {
      const response = await app.request(
        "/api/v1/groups/non-existent-group/events?from=2024-01-01T00:00:00%2B09:00&limit=10",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(404);
    });

    it("グループに参加していない場合は、グループがあることを明かさず404が返されること", async () => {
      const unauthorizedUser = await auth.createUser({ uid: "test_user_2" });
      const unauthorizedLoginResult = await login(unauthorizedUser);

      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&limit=10",
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

    it("カレンダーIDが設定されていない場合は500が返されること", async () => {
      await firestore
        .collection("groups")
        .doc("test_group_2")
        .set({
          name: "Test Group without Calendar",
          classes_calendar_id: "",
          events_calendar_id: "",
          dayduty_start_date: "",
          slack_event_channel_id: "",
          weather_point: { lat: 0, lon: 0 },
        });

      await grantGroup(user.uid, "test_group_2");

      const response = await app.request(
        "/api/v1/groups/test_group_2/events?from=2024-01-01T00:00:00%2B09:00&limit=10",
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

    it("不正な日付フォーマットの場合は400が返されること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=invalid-date&limit=10",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(400);
    });

    it("不正なtoパラメータの場合は400が返されること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&to=invalid-date&limit=10",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(400);
    });

    it("不正なlimitの場合は400が返されること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&limit=invalid",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(400);
    });

    it("正常にイベント一覧を取得できること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&limit=10",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(200);
      const json = await response.json();
      expect(json).toHaveProperty("items");
      expect(Array.isArray(json.items)).toBe(true);
    });

    it("時刻のあるイベントは、日本時間の日時で返すこと", async () => {
      mockFetchGoogleCalendarEvents.mockResolvedValueOnce({
        items: [
          {
            id: "meeting",
            summary: "説明会",
            start: { dateTime: "2024-01-01T01:00:00Z" },
            end: { dateTime: "2024-01-01T02:30:00Z" },
          },
        ],
      });

      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&limit=10",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(200);
      expect(await response.json()).toEqual({
        items: [
          {
            id: "meeting",
            startAt: "2024-01-01T10:00:00.000+09:00",
            endAt: "2024-01-01T11:30:00.000+09:00",
            title: "説明会",
            isAllDay: false,
          },
        ],
      });
    });

    it("日時のないイベントがあっても、ほかのイベントを返すこと", async () => {
      mockFetchGoogleCalendarEvents.mockResolvedValueOnce({
        items: [
          { id: "no-date", summary: "日時なし" },
          {
            id: "festival",
            summary: "文化祭",
            start: { date: "2024-01-01" },
            end: { date: "2024-01-02" },
          },
        ],
      });

      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&limit=10",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(200);
      expect(await response.json()).toEqual({
        items: [
          {
            id: "festival",
            startAt: "2024-01-01T00:00:00.000+09:00",
            endAt: "2024-01-02T00:00:00.000+09:00",
            title: "文化祭",
            isAllDay: true,
          },
        ],
      });
    });

    it("toパラメータありで正常にイベント一覧を取得できること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&to=2024-01-02T00:00:00%2B09:00&limit=10",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(200);
      const json = await response.json();
      expect(json).toHaveProperty("items");
      expect(Array.isArray(json.items)).toBe(true);
    });
  });
});
