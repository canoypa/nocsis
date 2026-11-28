import { DateTime } from "luxon";
import { firestore } from "../clients/firebase.js";
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
 * from から to まで (YYYY-MM-DD、どちらも含む) の日直
 *
 * 確定した日は書いてあるとおりに返し、その先は最後の確定から計算する。何も書かない
 *
 * 最初の確定より前の日は、日直なしとして返す。確定がひとつもなければ、全員 0 回から from の日に始める
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

  if (lastFinalized === undefined) {
    compute({ from, turns: {} }, to);
  } else if (lastFinalized < to) {
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
