import { beforeEach, describe, expect, it } from "vitest";

import { firestore } from "../clients/firebase.js";
import {
  planDaydutyMigration,
  writeDaydutyMigration,
} from "./dayduty_migration.js";
import { getDayduty } from "./dayduty_service.js";

const GROUP_ID = "test_group_migration";
const group = firestore.collection("groups").doc(GROUP_ID);

const deleteAll = async (query: FirebaseFirestore.Query) => {
  const snapshot = await query.get();
  for (const doc of snapshot.docs) await doc.ref.delete();
};

const addStudent = (id: string, stuNo: number) =>
  firestore.collection("classmates").doc(`migration_${id}`).set({
    group_id: GROUP_ID,
    role: "student",
    stuNo,
    name: id,
    slackUserId: id,
  });

const migrate = async (today: string) => {
  const plan = await planDaydutyMigration(GROUP_ID, today);
  if (plan.kind === "write") await writeDaydutyMigration(plan);
  return plan;
};

describe("日直の移行", () => {
  beforeEach(async () => {
    await group.set({ name: "Test Group", dayduty_start_date: "2025-01-01" });
    // 出席番号順に並べるのを確かめるため、順不同で入れる
    for (const [id, stuNo] of [
      ["C", 3],
      ["A", 1],
      ["D", 4],
      ["B", 2],
    ] as const) {
      await addStudent(id, stuNo);
    }
    await firestore.collection("classmates").doc("migration_T").set({
      group_id: GROUP_ID,
      role: "teacher",
      stuNo: 99,
      slackUserId: "T",
    });

    return async () => {
      await group.delete();
      await deleteAll(
        firestore.collection("classmates").where("group_id", "==", GROUP_ID),
      );
      await deleteAll(group.collection("dayduty_days"));
      await deleteAll(group.collection("dayduty_members"));
    };
  });

  it("移行した日から先は、開始日からの経過日数で決めていたときと同じ人が返されること", async () => {
    // 2025-01-03 は3日目なので C
    await migrate("2025-01-03");

    const days = await getDayduty(GROUP_ID, "2025-01-02", "2025-01-07");

    expect(days.map((day) => day.members.map((m) => m.name).join(""))).toEqual([
      "B",
      "C",
      "D",
      "A",
      "B",
      "C",
    ]);
  });

  it("前日の確定と、全員の使った番の数を書くこと", async () => {
    await migrate("2025-01-03");

    const days = await group.collection("dayduty_days").get();
    expect(days.docs.map((doc) => [doc.id, doc.get("members")])).toEqual([
      ["2025-01-02", ["migration_B"]],
    ]);
    const members = await group.collection("dayduty_members").get();
    expect(
      Object.fromEntries(members.docs.map((doc) => [doc.id, doc.get("turns")])),
    ).toEqual({
      migration_A: 1,
      migration_B: 1,
      migration_C: 0,
      migration_D: 0,
    });
  });

  it("二度流しても、変わらないこと", async () => {
    await migrate("2025-01-03");
    const second = await migrate("2025-01-05");

    expect(second).toMatchObject({
      kind: "skip",
      reason: "確定がもうあります",
    });
    const days = await group.collection("dayduty_days").get();
    expect(days.docs.map((doc) => doc.id)).toEqual(["2025-01-02"]);
  });

  it("書く間に確定ができていたら、書かないこと", async () => {
    const plan = await planDaydutyMigration(GROUP_ID, "2025-01-03");
    await group
      .collection("dayduty_days")
      .doc("2025-01-01")
      .set({ date: "2025-01-01", members: ["migration_A"], turns: {} });

    expect(plan.kind).toBe("write");
    await expect(
      writeDaydutyMigration(plan as Extract<typeof plan, { kind: "write" }>),
    ).rejects.toThrow("確定がもうあります");
    const days = await group.collection("dayduty_days").get();
    expect(days.docs.map((doc) => doc.id)).toEqual(["2025-01-01"]);
  });

  it("開始日に時刻が付いていても、日付で数えること", async () => {
    await group.set({
      name: "Test Group",
      dayduty_start_date: "2025-01-01T09:00:00",
    });

    const plan = await planDaydutyMigration(GROUP_ID, "2025-01-03");

    expect(plan).toMatchObject({ kind: "write", today: { name: "C" } });
  });

  it("今の式で当たる出席番号の生徒がいなければ、書かないこと", async () => {
    // 4人で 1・2・4・5 番。3日目は3番を探すのでいない
    await firestore.collection("classmates").doc("migration_C").delete();
    await addStudent("E", 5);

    const plan = await planDaydutyMigration(GROUP_ID, "2025-01-03");

    expect(plan).toMatchObject({
      kind: "skip",
      reason: "今の式で当たる出席番号の生徒がいません",
    });
  });

  it.each([
    ["開始日がない", { name: "Test Group" }, "日直の開始日がありません"],
    [
      "開始日の形が正しくない",
      { name: "Test Group", dayduty_start_date: "invalid" },
      "日直の開始日の形が正しくありません",
    ],
  ])("%s グループは、書かないこと", async (_, data, reason) => {
    await group.set(data);

    const plan = await planDaydutyMigration(GROUP_ID, "2025-01-03");

    expect(plan).toEqual({ groupId: GROUP_ID, kind: "skip", reason });
  });

  it("生徒がいないグループは、書かないこと", async () => {
    await deleteAll(
      firestore.collection("classmates").where("group_id", "==", GROUP_ID),
    );

    const plan = await planDaydutyMigration(GROUP_ID, "2025-01-03");

    expect(plan).toMatchObject({ kind: "skip", reason: "生徒がいません" });
  });
});
