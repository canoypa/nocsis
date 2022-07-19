import {
  getFunctions,
  httpsCallable,
  HttpsCallableResult,
} from "firebase/functions";
import { DateTime } from "luxon";
import { firebaseApp } from "../core/firebase_app";
import { EventsData } from "../types/events";

const toEventData = (res: HttpsCallableResult<any>): EventsData => {
  res.data.items = res.data.items.map((v: any) => ({
    title: v.title,
    isAllDay: v.isAllDay,
    startAt: DateTime.fromISO(v.startAt),
    endAt: DateTime.fromISO(v.endAt),
  }));

  return res.data;
};

export const getEvents = async (date: DateTime): Promise<EventsData> => {
  const functions = getFunctions(firebaseApp, "asia-northeast1");
  const getEventsFn = httpsCallable(functions, "v2-events-get");

  const from = date.startOf("day");

  return toEventData(
    await getEventsFn({
      from: from.toISO(),
      limit: 3,
    })
  );
};
