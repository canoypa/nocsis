import {
  getFunctions,
  httpsCallable,
  HttpsCallableResult,
} from "firebase/functions";
import { DateTime } from "luxon";
import { firebaseApp } from "../core/firebase_app";
import { ClassesData } from "../types/classes";

const toClassData = (res: HttpsCallableResult<any>): ClassesData => {
  res.data.items = res.data.items.map((v: any, i: number) => ({
    title: v.title,
    period: v.period,
    startAt: DateTime.fromISO(v.startAt),
    endAt: DateTime.fromISO(v.endAt),
  }));

  return res.data;
};

export const getClasses = async (date: DateTime): Promise<ClassesData> => {
  const functions = getFunctions(firebaseApp, "asia-northeast1");
  const getClassesFn = httpsCallable(functions, "v2-classes-get");

  const from = date.startOf("day");
  const to = from.plus({ days: 1 });

  return toClassData(
    await getClassesFn({
      from: from.toISO(),
      to: to.toISO(),
    })
  );
};
