import { getFirestore } from "firebase-admin/firestore";
import { functionsTest } from "tests/functions_setup.js";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import * as fetchWeatherModule from "~/services/weather/fetch_weather.js";
import { WeatherName } from "~/types/weather.js";
import { now } from "./index.js";

describe("now", () => {
  const wrapped = functionsTest.wrap(now);

  const mockedFetchWeather = vi
    .spyOn(fetchWeatherModule, "fetchWeather")
    .mockResolvedValue({
      current: { temp: 25, weather: [{ id: 235, main: "" }] },
      hourly: [
        { temp: 0, pop: 0.0, weather: [{ id: 235, main: "" }] },
        { temp: 1, pop: 0.1, weather: [{ id: 600, main: "" }] },
        { temp: 2, pop: 0.2, weather: [{ id: 701, main: "" }] },
        { temp: 3, pop: 0.3, weather: [{ id: 800, main: "" }] },
        { temp: 4, pop: 0.4, weather: [{ id: 803, main: "" }] },
        { temp: 5, pop: 0.5, weather: [{ id: 803, main: "" }] },
        { temp: 6, pop: 0.6, weather: [{ id: 803, main: "" }] },
        { temp: 7, pop: 0.7, weather: [{ id: 803, main: "" }] },
        { temp: 8, pop: 0.8, weather: [{ id: 803, main: "" }] },
        { temp: 9, pop: 0.9, weather: [{ id: 803, main: "" }] },
      ],
    });

  beforeEach(async () => {
    const firestore = getFirestore(firebaseApp);

    const userJoinedGroupsCollection = firestore.collection(
      "/user_joined_groups",
    );
    const groupCollection = firestore.collection("/groups");

    await userJoinedGroupsCollection.add({
      user_id: "user_a",
      group_id: "group_a",
      group_name: "Group A",
    });

    await groupCollection.doc("group_a").set({
      weather_point: {
        lat: 99,
        lon: 99,
      },
    });
  });

  it("正しい値が返されること", async () => {
    const auth = functionsTest.auth.makeUserRecord({
      uid: "user_a",
    });

    // @ts-expect-error
    const data = await wrapped({ auth, data: { groupId: "group_a" } });

    expect(mockedFetchWeather).toHaveBeenCalledWith({ lat: 99, lon: 99 });

    expect(data.current.temp).toBe(25);
    expect(data.current.name).toBe(WeatherName.Rain);

    expect(data.threeHour.length).toBe(3);
    expect(data.threeHour[0]).toBe(WeatherName.Snow);
    expect(data.threeHour[1]).toBe(WeatherName.Atmosphere);
    expect(data.threeHour[2]).toBe(WeatherName.Clear);

    expect(data.hourly.temp.length).toBe(9);
    expect(data.hourly.temp.at(0)).toBe(0);
    expect(data.hourly.temp.at(-1)).toBe(8);

    expect(data.hourly.pop.length).toBe(9);
    expect(data.hourly.pop.at(0)).toBe(0.0);
    expect(data.hourly.pop.at(-1)).toBe(0.8);
  });

  describe("認証されていない場合", () => {
    it("エラーになること", async () => {
      // @ts-expect-error
      await expect(wrapped({ data: { groupId: "group_a" } })).rejects.toThrow(
        "You must be authenticated to use this function",
      );
    });
  });

  describe("ユーザーが参加していないグループにアクセスした場合", () => {
    it("エラーになること", async () => {
      const auth = functionsTest.auth.makeUserRecord({
        uid: "user_b",
      });

      await expect(
        // @ts-expect-error
        wrapped({ auth, data: { groupId: "group_a" } }),
      ).rejects.toThrow("You are not a member of this group");
    });
  });
});
