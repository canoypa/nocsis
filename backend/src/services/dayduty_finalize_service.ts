import type { DocumentData, Transaction } from "firebase-admin/firestore";
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

type Turns = Record<string, number>;

/** 開始日や生徒がないなど、日直を決められないグループ */
export class DaydutyNotConfiguredError extends Error {}

const groupRef = (groupId: string) =>
  firestore.collection("groups").doc(groupId);

const daysAfter = (date: string, days: number) =>
  isoDate(DateTime.fromISO(date, { zone: "utc" }).plus({ days }));

/**
 * 今の式 (開始日からの経過日数を人数で割った余り + 1 番) で、until の日に務めた人と、
 * until を終えた時点の使った番の数を作る
 *
 * until に務めた人までは今の周を使い終えたので 1、ほかは 0。出席番号が 1 から欠けずに並んでいれば、
 * 翌日からの計算は今の式と同じ順に回る。欠けていると今の式と同じ順にならないので、決めない
 */
const startFromFormula = (
  group: DocumentData | undefined,
  students: readonly { id: string; stuNo: unknown }[],
  studentCount: number,
  until: string,
): { members: string[]; turns: Turns } => {
  if (!group?.dayduty_start_date) {
    throw new DaydutyNotConfiguredError("dayduty_start_date is not set");
  }
  const startDate = DateTime.fromISO(group.dayduty_start_date, {
    zone: AppConfig.TIMEZONE,
  });
  if (!startDate.isValid) {
    throw new DaydutyNotConfiguredError(
      "日直開始日のフォーマットが正しくありません",
    );
  }
  if (students.length === 0) {
    throw new DaydutyNotConfiguredError("No students found in group");
  }
  // 出席番号のない生徒は orderBy で読めないが、今の式の人数には入る
  if (
    students.length !== studentCount ||
    students.some((s, i) => s.stuNo !== i + 1)
  ) {
    throw new DaydutyNotConfiguredError(
      "出席番号が 1 から欠けずに並んでいません",
    );
  }

  // 画面は今の時刻で数える。開始日が日付だけなら、その日のどの時刻でも同じになる
  const elapsed = Math.floor(
    DateTime.fromISO(until, { zone: AppConfig.TIMEZONE })
      .diff(startDate)
      .as("days"),
  );
  if (elapsed < 0) {
    throw new DaydutyNotConfiguredError("日直の開始日より前です");
  }
  const position = elapsed % students.length;
  return {
    members: [students[position].id],
    turns: Object.fromEntries(
      students.map((s, i) => [s.id, i <= position ? 1 : 0]),
    ),
  };
};

const readInputs = async (tx: Transaction, groupId: string) => {
  const group = groupRef(groupId);
  const [
    groupSnapshot,
    classmates,
    studentCount,
    last,
    members,
    records,
    rules,
  ] = await Promise.all([
    tx.get(group),
    // role でも絞ると (group_id, role, stuNo) の複合インデックスが要る。
    // (group_id, stuNo) はあるので、それで読んで先生は後で外す
    tx.get(
      firestore
        .collection("classmates")
        .where("group_id", "==", groupId)
        .orderBy("stuNo"),
    ),
    tx.get(
      firestore
        .collection("classmates")
        .where("group_id", "==", groupId)
        .where("role", "==", "student")
        .count(),
    ),
    tx.get(group.collection("dayduty_days").orderBy("date", "desc").limit(1)),
    tx.get(group.collection("dayduty_members")),
    tx.get(group.collection("dayduty_records")),
    tx.get(group.collection("dayduty_rules")),
  ]);

  return {
    group: groupSnapshot.data(),
    students: classmates.docs
      .filter((doc) => doc.get("role") === "student")
      .map((doc) => ({ id: doc.id, stuNo: doc.get("stuNo") as unknown })),
    studentCount: studentCount.data().count,
    lastFinalized: last.docs[0]?.get("date") as string | undefined,
    turns: Object.fromEntries<number>(
      members.docs.map((doc) => [doc.id, doc.get("turns") as number]),
    ),
    ops: records.docs.flatMap((doc) => (doc.get("ops") ?? []) as DaydutyOp[]),
    rules: rules.docs.map((doc) => doc.data() as DaydutyRule),
  };
};

/**
 * 最後に確定した日の翌日から until (YYYY-MM-DD) までを確定する。確定した日の数を返す
 *
 * まだ確定した日がなければ、until の日だけを今の式で書く
 */
export const finalizeDayduty = async (
  groupId: string,
  until: string,
): Promise<number> =>
  firestore.runTransaction(async (tx) => {
    const { group, students, studentCount, lastFinalized, turns, ops, rules } =
      await readInputs(tx, groupId);
    if (lastFinalized !== undefined && lastFinalized >= until) return 0;

    const ref = groupRef(groupId);
    const writeDay = (date: string, members: string[], changed: Turns) => {
      tx.create(ref.collection("dayduty_days").doc(date), {
        date,
        members,
        turns: changed,
        finalized_at: FieldValue.serverTimestamp(),
      });
    };
    const writeTurns = (changed: Turns) => {
      for (const [id, value] of Object.entries(changed)) {
        tx.set(ref.collection("dayduty_members").doc(id), { turns: value });
      }
    };

    if (lastFinalized === undefined) {
      const start = startFromFormula(group, students, studentCount, until);
      writeDay(until, start.members, start.turns);
      writeTurns(start.turns);
      return 1;
    }

    const { days } = computeDayduty({
      order: students.map((s) => s.id),
      turns,
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
      if (err instanceof DaydutyNotConfiguredError) {
        console.warn("日直を確定できないグループを飛ばしました", {
          group: group.id,
          reason: err.message,
        });
        continue;
      }
      console.error("日直の確定に失敗しました", { group: group.id, err });
      failed.push(group.id);
    }
  }
  return failed;
};
