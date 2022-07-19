import { selector } from "recoil";
import { getEvents } from "../api/events";
import { DayState } from "./date";

export const EventSelector = selector({
  key: "EventSelector",
  get: async ({ get }) => {
    const date = get(DayState).plus({ days: 1 });
    return await getEvents(date);
  },
  cachePolicy_UNSTABLE: {
    eviction: "most-recent",
  },
});
