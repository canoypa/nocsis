import type { UserRecord } from "firebase-admin/auth";
import { beforeEach, describe, expect, it, vi } from "vitest";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";
import * as openWeatherMapServiceModule from "../../services/open_weather_map_service.js";

vi.mock("../../services/secret_manager_service.js", () => ({
  fetchSecret: vi.fn().mockResolvedValue("mock-secret"),
}));

describe("WeatherController", () => {
  describe("GET /api/v1/groups/:groupId/weather/now", () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      const groupRef = firestore.collection("groups").doc("test_group_1");
      await groupRef.set({
        id: "test_group_1",
        name: "Test Group",
        classes_calendar_id: "",
        events_calendar_id: "",
        dayduty_start_date: "",
        slack_event_channel_id: "",
        weather_point: { lat: 35.0, lon: 139.0 },
      });

      await firestore.collection("user_joined_groups").add({
        user_id: user.uid,
        group_id: "test_group_1",
      });

      return async () => {
        await auth.deleteUser(user.uid);
      };
    });

    it("気象情報のデータを取得できる", async () => {
      vi.spyOn(openWeatherMapServiceModule, "fetchWeather").mockResolvedValue({
        current: { temp: 20, weather: [{ id: 800, main: "Clear" }] },
        hourly: [
          { temp: 21, pop: 0.0, weather: [{ id: 803, main: "Clouds" }] },
          { temp: 22, pop: 0.1, weather: [{ id: 803, main: "Clouds" }] },
          { temp: 23, pop: 0.2, weather: [{ id: 803, main: "Clouds" }] },
          { temp: 24, pop: 0.3, weather: [{ id: 803, main: "Clouds" }] },
          { temp: 25, pop: 0.4, weather: [{ id: 803, main: "Clouds" }] },
          { temp: 26, pop: 0.5, weather: [{ id: 803, main: "Clouds" }] },
          { temp: 27, pop: 0.6, weather: [{ id: 803, main: "Clouds" }] },
          { temp: 28, pop: 0.7, weather: [{ id: 803, main: "Clouds" }] },
        ],
      });

      const res = await app.request("/api/v1/groups/test_group_1/weather/now", {
        headers: {
          Authorization: `Bearer ${loginResult.idToken}`,
          Accept: "application/json",
        },
      });

      const body = await res.json();

      expect(res.status).toBe(200);
      expect(body).toEqual({
        current: { temp: 20, name: "Clear" },
        hourly: {
          temp: [21, 22, 23, 24, 25, 26, 27, 28],
          pop: [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7],
        },
        threeHour: ["Clouds", "Clouds", "Clouds"],
      });
    });

    describe("認証情報がない場合", () => {
      it("401 Unauthorized を返す", async () => {
        const res = await app.request(
          "/api/v1/groups/test_group_1/weather/now",
          { headers: { Accept: "application/json" } },
        );

        expect(res.status).toBe(401);
      });
    });

    it("should return 403 if not joined group", async () => {
      // 他のユーザーでアクセス
      const other = await auth.createUser({ uid: "user2" });
      const loginOther = await login(other);
      const res = await app.request("/api/v1/groups/test_group_1/weather/now", {
        headers: { Authorization: `Bearer ${loginOther.idToken}` },
      });
      await auth.deleteUser(other.uid);
      expect(res.status).toBe(403);
    });

    it("should return 404 if group not found", async () => {
      const res = await app.request("/api/v1/groups/nonexistent/weather/now", {
        headers: { Authorization: `Bearer ${loginResult.idToken}` },
      });
      expect(res.status).toBe(404);
    });

    it("should return 500 if weather_point missing", async () => {
      // グループ更新
      await firestore
        .collection("groups")
        .doc("test_group_1")
        .update({ weather_point: null });
      const res = await app.request("/api/v1/groups/test_group_1/weather/now", {
        headers: { Authorization: `Bearer ${loginResult.idToken}` },
      });
      expect(res.status).toBe(500);
    });
  });
});
