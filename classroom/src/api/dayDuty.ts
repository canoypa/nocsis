import { getFunctions, httpsCallable } from "firebase/functions";
import { DateTime } from "luxon";
import { firebaseApp } from "../core/firebase_app";
import { DaydutyData } from "../types/dayduty";

export const getDayduty = async (date: DateTime): Promise<DaydutyData> => {
  const functions = getFunctions(firebaseApp, "asia-northeast1");
  const getDaydutyFn = httpsCallable(functions, "v2-dayduty-get");

  const { data } = await getDaydutyFn({
    date: date.startOf("day").toISO(),
  });

  return data as DaydutyData;
};
