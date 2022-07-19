import { selector } from "recoil";
import { getDayduty } from "../api/dayDuty";
import { DayState } from "./date";

export const DaydutyState = selector({
  key: "DaydutyState",
  get: async ({ get }) => {
    const date = get(DayState);
    return await getDayduty(date);
  },
  cachePolicy_UNSTABLE: {
    eviction: "most-recent",
  },
});
