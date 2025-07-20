import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";

vi.mock("../../services/google_calendar_service.js", () => ({
  fetchGoogleCalendarEvents: vi.fn().mockResolvedValue({ items: [] }),
}));

describe("Events Controller", () => {
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
        events_calendar_id: "test-calendar-id",
        classes_calendar_id: "",
        dayduty_start_date: "",
        slack_event_channel_id: "",
        weather_point: { lat: 0, lon: 0 },
      });

    await firestore.collection("user_joined_groups").add({
      user_id: user.uid,
      group_id: "test_group_1",
      created_at: new Date(),
    });
  });

  afterEach(async () => {
    await auth.deleteUser(user.uid);
    await firestore.collection("groups").doc("test_group_1").delete();

    const userJoinedGroupsSnapshot = await firestore
      .collection("user_joined_groups")
      .where("user_id", "==", user.uid)
      .where("group_id", "==", "test_group_1")
      .get();

    const batch = firestore.batch();
    for (const doc of userJoinedGroupsSnapshot.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
  });

  describe("GET /:groupId/events", () => {
    it("認証が必要であること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&to=2024-01-02T00:00:00%2B09:00",
        {
          method: "GET",
        },
      );

      expect(response.status).toBe(401);
    });

    it("グループが存在しない場合は404が返されること", async () => {
      const response = await app.request(
        "/api/v1/groups/non-existent-group/events?from=2024-01-01T00:00:00%2B09:00&to=2024-01-02T00:00:00%2B09:00",
        {
          method: "GET",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
          },
        },
      );

      expect(response.status).toBe(404);
    });

    it("グループに参加していない場合は403が返されること", async () => {
      const unauthorizedUser = await auth.createUser({ uid: "test_user_2" });
      const unauthorizedLoginResult = await login(unauthorizedUser);

      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&to=2024-01-02T00:00:00%2B09:00",
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

      await firestore.collection("user_joined_groups").add({
        user_id: user.uid,
        group_id: "test_group_2",
        created_at: new Date(),
      });

      const response = await app.request(
        "/api/v1/groups/test_group_2/events?from=2024-01-01T00:00:00%2B09:00&to=2024-01-02T00:00:00%2B09:00",
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

    it("不正な日付フォーマットの場合は400が返されること", async () => {
      const response = await app.request(
        "/api/v1/groups/test_group_1/events?from=invalid-date&to=2024-01-02T00:00:00%2B09:00",
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
        "/api/v1/groups/test_group_1/events?from=2024-01-01T00:00:00%2B09:00&to=2024-01-02T00:00:00%2B09:00",
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
