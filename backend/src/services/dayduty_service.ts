import { DateTime } from "luxon";
import { firestore } from "../clients/firebase.js";
import { AppConfig } from "../config/app_config.js";
import {
  computeDayduty,
  type DaydutyOp,
  type DaydutyRule,
} from "./dayduty_calc.js";

export type DaydutyMember = { id: string; name: string };
export type DaydutyOfDay = { date: string; members: DaydutyMember[] };

const groupRef = (groupId: string) =>
  firestore.collection("groups").doc(groupId);

const daysAfter = (date: string, days: number) =>
  DateTime.fromISO(date, { zone: "utc" }).plus({ days }).toISODate() as string;

/**
 * 決めた順番に並んだ生徒。今は出席番号順
 */
const loadOrder = async (groupId: string) => {
  const snapshot = await firestore
    .collection("classmates")
    .where("group_id", "==", groupId)
    .where("role", "==", "student")
    .get();
  return snapshot.docs
    .map((doc) => ({
      id: doc.id,
      name: doc.get("name") as string,
      stuNo: doc.get("stuNo") as number,
    }))
    .sort((a, b) => a.stuNo - b.stuNo);
};

/**
 * まだ確定した日がないグループは、開始日からの経過日数で決めていたときと同じ人から始める
 */
const turnsFromStartDate = async (
  groupId: string,
  order: readonly string[],
  date: string,
): Promise<Record<string, number>> => {
  const group = (await groupRef(groupId).get()).data();
  if (!group) {
    throw new Error("Group not found");
  }
  if (!group.dayduty_start_date) {
    throw new Error("dayduty_start_date is not set");
  }
  const startDate = DateTime.fromISO(group.dayduty_start_date, {
    zone: AppConfig.TIMEZONE,
  });
  if (!startDate.isValid) {
    throw new Error("日直開始日のフォーマットが正しくありません");
  }
  if (order.length === 0) {
    throw new Error("No students found in group");
  }

  const elapsedDays = Math.floor(
    DateTime.fromISO(date, { zone: AppConfig.TIMEZONE })
      .diff(startDate)
      .as("days"),
  );
  const first = ((elapsedDays % order.length) + order.length) % order.length;
  return Object.fromEntries(order.map((m, i) => [m, i < first ? 1 : 0]));
};

/**
 * from から to まで (YYYY-MM-DD、どちらも含む) の日直
 *
 * 確定した日は書いてあるとおりに返し、その先は最後の確定から計算する。何も書かない
 */
export const getDayduty = async (
  groupId: string,
  from: string,
  to: string,
): Promise<DaydutyOfDay[]> => {
  const daysRef = groupRef(groupId).collection("dayduty_days");

  const [order, lastSnapshot, recordsSnapshot, rulesSnapshot] =
    await Promise.all([
      loadOrder(groupId),
      daysRef.orderBy("date", "desc").limit(1).get(),
      groupRef(groupId).collection("dayduty_records").get(),
      groupRef(groupId).collection("dayduty_rules").get(),
    ]);
  const orderIds = order.map((m) => m.id);
  const lastFinalized = lastSnapshot.docs[0]?.get("date") as string | undefined;

  const finalized = new Map<string, string[]>();
  if (lastFinalized !== undefined && from <= lastFinalized) {
    const snapshot = await daysRef
      .where("date", ">=", from)
      .where("date", "<=", to)
      .get();
    for (const doc of snapshot.docs) {
      finalized.set(doc.get("date"), doc.get("members"));
    }
  }

  const computed = new Map<string, string[]>();
  if (lastFinalized === undefined || lastFinalized < to) {
    const computeFrom =
      lastFinalized === undefined ? from : daysAfter(lastFinalized, 1);
    const turns =
      lastFinalized === undefined
        ? await turnsFromStartDate(groupId, orderIds, computeFrom)
        : Object.fromEntries(
            (
              await groupRef(groupId).collection("dayduty_members").get()
            ).docs.map((doc) => [doc.id, doc.get("turns") as number]),
          );

    const { days } = computeDayduty({
      order: orderIds,
      turns,
      from: computeFrom,
      to,
      ops: recordsSnapshot.docs.flatMap((doc) => doc.get("ops") as DaydutyOp[]),
      rules: rulesSnapshot.docs.map((doc) => doc.data() as DaydutyRule),
    });
    for (const day of days) computed.set(day.date, day.members);
  }

  const names = new Map(order.map((m) => [m.id, m.name]));
  const result: DaydutyOfDay[] = [];
  for (let date = from; date <= to; date = daysAfter(date, 1)) {
    const ids = finalized.get(date) ?? computed.get(date) ?? [];
    result.push({
      date,
      members: ids.flatMap((id) => {
        const name = names.get(id);
        return name === undefined ? [] : [{ id, name }];
      }),
    });
  }
  return result;
};
