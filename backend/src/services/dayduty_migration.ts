import { FieldValue } from "firebase-admin/firestore";
import { DateTime } from "luxon";

import { firestore } from "../clients/firebase.js";
import { isoDate } from "./dayduty_calc.js";

export type DaydutyMigrationPlan =
  | {
      groupId: string;
      kind: "write";
      /** 確定として書く日。移行する日の前日 */
      date: string;
      /** 前日と今日に、今の式で当たる生徒 */
      yesterday: { id: string; name: string };
      today: { id: string; name: string };
      turns: Record<string, number>;
    }
  | { groupId: string; kind: "skip"; reason: string };

/**
 * 今の式 (開始日からの経過日数を人数で割った余り + 1 番) で決めていた日直を、
 * 前日の確定と使った番の数として書く形にする
 *
 * 今日の人より前の順番の人は今の周を使い終えたので 1、ほかは 0。そうすると、今日からの計算は今の式と同じ順に回る
 */
export const planDaydutyMigration = async (
  groupId: string,
  today: string,
): Promise<DaydutyMigrationPlan> => {
  const group = firestore.collection("groups").doc(groupId);
  const [groupSnapshot, finalized, classmates] = await Promise.all([
    group.get(),
    group.collection("dayduty_days").limit(1).get(),
    firestore.collection("classmates").where("group_id", "==", groupId).get(),
  ]);
  const skip = (reason: string): DaydutyMigrationPlan => ({
    groupId,
    kind: "skip",
    reason,
  });

  if (!finalized.empty) return skip("確定がもうあります");
  const startDate = groupSnapshot.get("dayduty_start_date");
  if (!startDate) return skip("日直の開始日がありません");
  const start = DateTime.fromISO(startDate, { zone: "utc" });
  if (!start.isValid) return skip("日直の開始日の形が正しくありません");

  const students = classmates.docs
    .filter((doc) => doc.get("role") === "student")
    .map((doc) => ({
      id: doc.id,
      name: doc.get("name") as string,
      stuNo: doc.get("stuNo") as number,
    }))
    .toSorted((a, b) => a.stuNo - b.stuNo);
  if (students.length === 0) return skip("生徒がいません");

  const date = isoDate(
    DateTime.fromISO(today, { zone: "utc" }).minus({ days: 1 }),
  );
  const dutyOn = (day: string) => {
    const elapsed = DateTime.fromISO(day, { zone: "utc" })
      .diff(start.startOf("day"), "days")
      .as("days");
    const stuNo = (elapsed % students.length) + 1;
    return students.find((s) => s.stuNo === stuNo);
  };
  const yesterday = dutyOn(date);
  const todays = dutyOn(today);
  // 今の式で当たる出席番号の生徒がいない日は、今の画面も 500 になっている。どこから始めるかを決められない
  if (yesterday === undefined || todays === undefined)
    return skip("今の式で当たる出席番号の生徒がいません");

  const position = students.indexOf(todays);
  return {
    groupId,
    kind: "write",
    date,
    yesterday: { id: yesterday.id, name: yesterday.name },
    today: { id: todays.id, name: todays.name },
    turns: Object.fromEntries(
      students.map((s, i) => [s.id, i < position ? 1 : 0]),
    ),
  };
};

/**
 * 移行を書く。確定はトランザクションで create するので、同じ日の確定がもうあれば書かない
 */
export const writeDaydutyMigration = async (
  plan: Extract<DaydutyMigrationPlan, { kind: "write" }>,
): Promise<void> => {
  const group = firestore.collection("groups").doc(plan.groupId);
  await firestore.runTransaction(async (tx) => {
    const finalized = await tx.get(group.collection("dayduty_days").limit(1));
    if (!finalized.empty) throw new Error("確定がもうあります");

    tx.create(group.collection("dayduty_days").doc(plan.date), {
      date: plan.date,
      members: [plan.yesterday.id],
      turns: plan.turns,
      finalized_at: FieldValue.serverTimestamp(),
    });
    for (const [id, turns] of Object.entries(plan.turns)) {
      tx.set(group.collection("dayduty_members").doc(id), { turns });
    }
  });
};
