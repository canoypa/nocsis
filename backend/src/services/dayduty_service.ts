import type {
  DocumentReference,
  DocumentSnapshot,
  Query,
  QuerySnapshot,
  Transaction,
} from "firebase-admin/firestore";
import { FieldValue } from "firebase-admin/firestore";
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

type Turns = Record<string, number>;

type Reader = {
  doc: (ref: DocumentReference) => Promise<DocumentSnapshot>;
  query: (query: Query) => Promise<QuerySnapshot>;
};

const transactionReader = (tx: Transaction): Reader => ({
  doc: (ref) => tx.get(ref),
  query: (query) => tx.get(query),
});

const groupRef = (groupId: string) =>
  firestore.collection("groups").doc(groupId);

const daysAfter = (date: string, days: number) =>
  isoDate(DateTime.fromISO(date, { zone: "utc" }).plus({ days }));

/**
 * 計算に使うものをまとめて読む。順番は名簿の出席番号順
 */
const loadInputs = async (groupId: string, read: Reader) => {
  const group = groupRef(groupId);
  const [classmates, last, records, rules] = await Promise.all([
    // role でも絞ると (group_id, role, stuNo) の複合インデックスが要る。
    // (group_id, stuNo) はあるので、それで読んで先生は後で外す
    read.query(
      firestore
        .collection("classmates")
        .where("group_id", "==", groupId)
        .orderBy("stuNo"),
    ),
    read.query(
      group.collection("dayduty_days").orderBy("date", "desc").limit(1),
    ),
    read.query(group.collection("dayduty_records")),
    read.query(group.collection("dayduty_rules")),
  ]);

  const order = classmates.docs
    .filter((doc) => doc.get("role") === "student")
    .map((doc) => ({ id: doc.id, name: doc.get("name") as string }));

  return {
    order,
    lastFinalized: last.docs[0]?.get("date") as string | undefined,
    ops: records.docs.flatMap((doc) => doc.get("ops") as DaydutyOp[]),
    rules: rules.docs.map((doc) => doc.data() as DaydutyRule),
  };
};

const loadTurns = async (groupId: string, read: Reader): Promise<Turns> => {
  const snapshot = await read.query(
    groupRef(groupId).collection("dayduty_members"),
  );
  return Object.fromEntries(
    snapshot.docs.map((doc) => [doc.id, doc.get("turns") as number]),
  );
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
): Promise<DaydutyOfDay[]> =>
  // 確定ジョブが最後の確定日と使った番の数を一緒に書き換えるので、同じ時点のものを読む
  firestore.runTransaction(
    (tx) => readDayduty(groupId, from, to, transactionReader(tx)),
    { readOnly: true },
  );

const readDayduty = async (
  groupId: string,
  from: string,
  to: string,
  read: Reader,
): Promise<DaydutyOfDay[]> => {
  const { order, lastFinalized, ops, rules } = await loadInputs(groupId, read);
  const orderIds = order.map((m) => m.id);

  const members = new Map<string, string[]>();
  const compute = (start: { from: string; turns: Turns }, until: string) => {
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
    const snapshot = await read.query(
      groupRef(groupId)
        .collection("dayduty_days")
        .where("date", ">=", from)
        .where("date", "<=", to),
    );
    for (const doc of snapshot.docs) {
      members.set(doc.get("date"), doc.get("members"));
    }
  }

  if (lastFinalized === undefined) {
    compute({ from, turns: {} }, to);
  } else if (lastFinalized < to) {
    compute(
      {
        from: daysAfter(lastFinalized, 1),
        turns: await loadTurns(groupId, read),
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

/**
 * 最後に確定した日の翌日から until (YYYY-MM-DD) までを確定する。確定した日の数を返す
 *
 * まだ確定した日がなければ、全員 0 回から until の日だけを書く。ふつうは移行で前日の確定が入っている
 */
export const finalizeDayduty = async (
  groupId: string,
  until: string,
): Promise<number> =>
  firestore.runTransaction(async (tx) => {
    const read = transactionReader(tx);
    const { order, lastFinalized, ops, rules } = await loadInputs(
      groupId,
      read,
    );
    if (lastFinalized !== undefined && lastFinalized >= until) return 0;

    const orderIds = order.map((m) => m.id);
    const group = groupRef(groupId);
    const writeDay = (date: string, members: string[], turns: Turns) => {
      tx.create(group.collection("dayduty_days").doc(date), {
        date,
        members,
        turns,
        finalized_at: FieldValue.serverTimestamp(),
      });
    };
    const writeTurns = (turns: Turns) => {
      for (const [id, value] of Object.entries(turns)) {
        tx.set(group.collection("dayduty_members").doc(id), { turns: value });
      }
    };

    if (lastFinalized === undefined) {
      const { days, turns } = computeDayduty({
        order: orderIds,
        turns: {},
        from: until,
        to: until,
        ops,
        rules,
      });
      writeDay(until, days[0].members, turns);
      writeTurns(turns);
      return 1;
    }

    const { days } = computeDayduty({
      order: orderIds,
      turns: await loadTurns(groupId, read),
      from: daysAfter(lastFinalized, 1),
      to: until,
      ops,
      rules,
    });
    const changed: Turns = {};
    for (const day of days) {
      writeDay(day.date, day.members, day.turns);
      Object.assign(changed, day.turns);
    }
    writeTurns(changed);
    return days.length;
  });

/**
 * すべてのグループで、昨日までの日直を確定する。確定できなかったグループの ID を返す
 */
export const finalizeAllDayduty = async (now: DateTime): Promise<string[]> => {
  const yesterday = isoDate(now.setZone(AppConfig.TIMEZONE).minus({ days: 1 }));
  const groups = await firestore.collection("groups").select().get();

  const failed: string[] = [];
  for (const group of groups.docs) {
    try {
      await finalizeDayduty(group.id, yesterday);
    } catch (err) {
      console.error("日直の確定に失敗しました", { group: group.id, err });
      failed.push(group.id);
    }
  }
  return failed;
};
