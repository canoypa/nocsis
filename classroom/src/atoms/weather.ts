import { selector } from "recoil";
import { getWeather } from "../api/weather";
import { CronDateState } from "./date";

export const WeatherState = selector({
  key: "WeatherState",
  get: async ({ get }) => {
    // 15分毎に更新する
    get(CronDateState("0,15,30,45 * * * *"));

    return await getWeather();
  },
  cachePolicy_UNSTABLE: {
    eviction: "most-recent",
  },
});
