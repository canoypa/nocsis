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
 * until に務めた人までは今の周を使い終えたので 1、ほかは 0。そうすると、翌日からの計算は今の式と同じ順に回る
 */
const startFromFormula = (
  group: DocumentData | undefined,
  students: readonly { id: string; stuNo: number }[],
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

  // 画面と同じく、その日の 0 時から数える
  const dutyOn = (day: string) => {
    const elapsed = Math.floor(
      DateTime.fromISO(day, { zone: AppConfig.TIMEZONE })
        .diff(startDate)
        .as("days"),
    );
    const stuNo = (elapsed % students.length) + 1;
    const student = students.find((s) => s.stuNo === stuNo);
    if (student === undefined) {
      // 今の画面もこの日は 500 になっている。どこから始めるかを決められない
      throw new DaydutyNotConfiguredError(
        `${day} に当たる出席番号の生徒がいません`,
      );
    }
    return student;
  };

  const served = dutyOn(until);
  const position = students.indexOf(served);
  return {
    members: [served.id],
    turns: Object.fromEntries(
      students.map((s, i) => [s.id, i <= position ? 1 : 0]),
    ),
  };
};

const readInputs = async (tx: Transaction, groupId: string) => {
  const group = groupRef(groupId);
  const [groupSnapshot, classmates, last, members, records, rules] =
    await Promise.all([
      tx.get(group),
      // role でも絞ると (group_id, role, stuNo) の複合インデックスが要る。
      // (group_id, stuNo) はあるので、それで読んで先生は後で外す
      tx.get(
        firestore
          .collection("classmates")
          .where("group_id", "==", groupId)
          .orderBy("stuNo"),
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
      .map((doc) => ({ id: doc.id, stuNo: doc.get("stuNo") as number })),
    lastFinalized: last.docs[0]?.get("date") as string | undefined,
    turns: Object.fromEntries<number>(
      members.docs.map((doc) => [doc.id, doc.get("turns") as number]),
    ),
    ops: records.docs.flatMap((doc) => doc.get("ops") as DaydutyOp[]),
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
    const { group, students, lastFinalized, turns, ops, rules } =
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
      const start = startFromFormula(group, students, until);
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
      if (err instanceof DaydutyNotConfiguredError) continue;
      console.error("日直の確定に失敗しました", { group: group.id, err });
      failed.push(group.id);
    }
  }
  return failed;
};
