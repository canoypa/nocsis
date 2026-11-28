import { DateTime } from "luxon";
import { firestore } from "../clients/firebase.js";
import { AppConfig } from "../config/app_config.js";
import {
  computeDayduty,
  type DaydutyOp,
  type DaydutyRule,
  isoDate,
} from "./dayduty_calc.js";

export type DaydutyMember = { id: string; name: string };
export type DaydutyOfDay = { date: string; members: DaydutyMember[] };

const groupRef = (groupId: string) =>
  firestore.collection("groups").doc(groupId);

const daysAfter = (date: string, days: number) =>
  isoDate(DateTime.fromISO(date, { zone: "utc" }).plus({ days }));

/**
 * 決めた順番に並んだ生徒。今は出席番号順
 */
const loadOrder = async (groupId: string) => {
  // role でも絞ると (group_id, role, stuNo) の複合インデックスが要る。
  // (group_id, stuNo) はあるので、それで読んで先生はここで外す
  const snapshot = await firestore
    .collection("classmates")
    .where("group_id", "==", groupId)
    .orderBy("stuNo")
    .get();
  return snapshot.docs
    .filter((doc) => doc.get("role") === "student")
    .map((doc) => ({ id: doc.id, name: doc.get("name") as string }));
};

/**
 * 確定した日がない日は、開始日からの経過日数で決めていたときと同じ人になるよう、開始日から数え直す
 *
 * 開始日より前の日を読むときは、その日から始める
 */
const startOfRotation = async (
  groupId: string,
  order: readonly string[],
  from: string,
): Promise<{ from: string; turns: Record<string, number> }> => {
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

  const start = isoDate(startDate);
  const seed = from < start ? from : start;
  const elapsedDays = DateTime.fromISO(seed, { zone: "utc" })
    .diff(DateTime.fromISO(start, { zone: "utc" }), "days")
    .as("days");
  const first = ((elapsedDays % order.length) + order.length) % order.length;
  return {
    from: seed,
    turns: Object.fromEntries(order.map((m, i) => [m, i < first ? 1 : 0])),
  };
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
  const ops = recordsSnapshot.docs.flatMap(
    (doc) => doc.get("ops") as DaydutyOp[],
  );
  const rules = rulesSnapshot.docs.map((doc) => doc.data() as DaydutyRule);
  const lastFinalized = lastSnapshot.docs[0]?.get("date") as string | undefined;

  const members = new Map<string, string[]>();
  const compute = (
    start: { from: string; turns: Record<string, number> },
    until: string,
  ) => {
    const { days } = computeDayduty({
      order: orderIds,
      turns: start.turns,
      from: start.from,
      to: until,
      ops,
      rules,
    });
    for (const day of days) {
      if (!members.has(day.date)) members.set(day.date, day.members);
    }
  };

  if (lastFinalized !== undefined && from <= lastFinalized) {
    const snapshot = await daysRef
      .where("date", ">=", from)
      .where("date", "<=", to)
      .get();
    for (const doc of snapshot.docs) {
      members.set(doc.get("date"), doc.get("members"));
    }
  }

  const finalizedUntil =
    lastFinalized !== undefined && lastFinalized < to ? lastFinalized : to;
  let missing = false;
  for (let date = from; date <= finalizedUntil; date = daysAfter(date, 1)) {
    if (!members.has(date)) missing = true;
  }
  if (lastFinalized === undefined || missing) {
    const until = lastFinalized === undefined ? to : finalizedUntil;
    compute(await startOfRotation(groupId, orderIds, from), until);
  }

  if (lastFinalized !== undefined && lastFinalized < to) {
    const snapshot = await groupRef(groupId)
      .collection("dayduty_members")
      .get();
    compute(
      {
        from: daysAfter(lastFinalized, 1),
        turns: Object.fromEntries(
          snapshot.docs.map((doc) => [doc.id, doc.get("turns") as number]),
        ),
      },
      to,
    );
  }

  const names = new Map(order.map((m) => [m.id, m.name]));
  const result: DaydutyOfDay[] = [];
  for (let date = from; date <= to; date = daysAfter(date, 1)) {
    result.push({
      date,
      members: (members.get(date) ?? []).flatMap((id) => {
        const name = names.get(id);
        return name === undefined ? [] : [{ id, name }];
      }),
    });
  }
  return result;
};
