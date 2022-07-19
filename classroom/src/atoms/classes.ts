import { selector } from "recoil";
import { getClasses } from "../api/classes";
import { DayState } from "./date";

export const ClassesSelector = selector({
  key: "ClassesSelector",
  get: async ({ get }) => {
    const date = get(DayState);
    return await getClasses(date);
  },
  cachePolicy_UNSTABLE: {
    eviction: "most-recent",
  },
});
