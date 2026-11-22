import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { clearBindings, grantGroup } from "../../../tests/helpers/bindings.js";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";
import * as openMeteoServiceModule from "../../services/open_meteo_service.js";

afterEach(clearBindings);

describe("WeatherController", () => {
  describe("GET /api/v1/groups/:groupId/weather/now", () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      const groupRef = firestore.collection("groups").doc("test_group_1");
      await groupRef.set({
        name: "Test Group",
        classes_calendar_id: "",
        events_calendar_id: "",
        dayduty_start_date: "",
        slack_event_channel_id: "",
        weather_point: { lat: 35.0, lon: 139.0 },
      });

      await grantGroup(user.uid, "test_group_1");

      return async () => {
        await auth.deleteUser(user.uid);
      };
    });

    it("気象情報のデータを取得できる", async () => {
      vi.spyOn(openMeteoServiceModule, "fetchWeather").mockResolvedValue({
        current: { temp: 20, weatherCode: 0 },
        hourly: [
          { temp: 21, pop: 0.0, weatherCode: 3 },
          { temp: 22, pop: 0.1, weatherCode: 3 },
          { temp: 23, pop: 0.2, weatherCode: 3 },
          { temp: 24, pop: 0.3, weatherCode: 3 },
          { temp: 25, pop: 0.4, weatherCode: 3 },
          { temp: 26, pop: 0.5, weatherCode: 3 },
          { temp: 27, pop: 0.6, weatherCode: 3 },
          { temp: 28, pop: 0.7, weatherCode: 3 },
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

    it("should return 404 without revealing the group if not joined", async () => {
      // 他のユーザーでアクセス
      const other = await auth.createUser({ uid: "user2" });
      const loginOther = await login(other);
      const res = await app.request("/api/v1/groups/test_group_1/weather/now", {
        headers: { Authorization: `Bearer ${loginOther.idToken}` },
      });
      await auth.deleteUser(other.uid);
      expect(res.status).toBe(404);
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
