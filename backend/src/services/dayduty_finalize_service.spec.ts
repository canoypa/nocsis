import { DateTime } from "luxon";
import { beforeEach, describe, expect, it } from "vitest";

import { firestore } from "../clients/firebase.js";
import {
  DaydutyNotConfiguredError,
  finalizeAllDayduty,
  finalizeDayduty,
} from "./dayduty_finalize_service.js";

const GROUP_ID = "test_group_finalize";
const group = firestore.collection("groups").doc(GROUP_ID);

const deleteCollection = async (ref: FirebaseFirestore.Query) => {
  const snapshot = await ref.get();
  const batch = firestore.batch();
  for (const doc of snapshot.docs) batch.delete(doc.ref);
  await batch.commit();
};

const addStudent = (id: string, stuNo: number) =>
  firestore.collection("classmates").doc(id).set({
    group_id: GROUP_ID,
    role: "student",
    stuNo,
    name: id,
    slackUserId: id,
  });

const finalizedDays = async () =>
  (await group.collection("dayduty_days").orderBy("date").get()).docs.map(
    (doc) => ({
      date: doc.get("date"),
      members: doc.get("members"),
      turns: doc.get("turns"),
    }),
  );

const storedTurns = async () =>
  Object.fromEntries(
    (await group.collection("dayduty_members").get()).docs.map((doc) => [
      doc.id,
      doc.get("turns"),
    ]),
  );

const membersOf = async () =>
  (await finalizedDays()).map((day) => (day.members as string[]).join(""));

describe("finalizeDayduty", () => {
  beforeEach(async () => {
    // 2026-11-30 に A から始まる
    await group.set({ name: "Test Group", dayduty_start_date: "2026-11-30" });
    for (const [id, stuNo] of [
      ["A", 1],
      ["B", 2],
      ["C", 3],
      ["D", 4],
    ] as const) {
      await addStudent(id, stuNo);
    }

    return async () => {
      await group.delete();
      await deleteCollection(
        firestore.collection("classmates").where("group_id", "==", GROUP_ID),
      );
      for (const sub of [
        "dayduty_days",
        "dayduty_members",
        "dayduty_records",
        "dayduty_rules",
      ]) {
        await deleteCollection(group.collection(sub));
      }
    };
  });

  it("最初の確定は、その日と全員の使った番の数を書くこと", async () => {
    expect(await finalizeDayduty(GROUP_ID, "2026-12-01")).toBe(1);

    expect(await finalizedDays()).toEqual([
      {
        date: "2026-12-01",
        members: ["B"],
        turns: { A: 1, B: 1, C: 0, D: 0 },
      },
    ]);
    expect(await storedTurns()).toEqual({ A: 1, B: 1, C: 0, D: 0 });
  });

  it("続きの確定は、最後の確定の翌日から書き、変わった人だけを書くこと", async () => {
    await finalizeDayduty(GROUP_ID, "2026-12-01");

    expect(await finalizeDayduty(GROUP_ID, "2026-12-03")).toBe(2);

    expect((await finalizedDays()).slice(1)).toEqual([
      { date: "2026-12-02", members: ["C"], turns: { C: 1 } },
      { date: "2026-12-03", members: ["D"], turns: { D: 1 } },
    ]);
    expect(await storedTurns()).toEqual({ A: 1, B: 1, C: 1, D: 1 });
  });

  it("もう確定した日までなら、何も書かないこと", async () => {
    await finalizeDayduty(GROUP_ID, "2026-12-02");
    const before = await finalizedDays();

    expect(await finalizeDayduty(GROUP_ID, "2026-12-02")).toBe(0);
    expect(await finalizeDayduty(GROUP_ID, "2026-12-01")).toBe(0);

    expect(await finalizedDays()).toEqual(before);
  });

  it("同時に走っても、同じ日を二重に書かないこと", async () => {
    await finalizeDayduty(GROUP_ID, "2026-12-01");

    await Promise.all([
      finalizeDayduty(GROUP_ID, "2026-12-04"),
      finalizeDayduty(GROUP_ID, "2026-12-04"),
    ]);

    expect((await finalizedDays()).map((d) => d.members.join(""))).toEqual([
      "B",
      "C",
      "D",
      "A",
    ]);
    expect(await storedTurns()).toEqual({ A: 2, B: 1, C: 1, D: 1 });
  });

  it("確定した日は、開始日からの経過日数で決めていたときと同じ人になること", async () => {
    await finalizeDayduty(GROUP_ID, "2026-12-01");
    await finalizeDayduty(GROUP_ID, "2026-12-08");

    // 2026-11-30 の A から、1日ごとに出席番号順
    expect(await membersOf()).toEqual(["B", "C", "D", "A", "B", "C", "D", "A"]);
  });

  it("先生が飛ばした番と、選ばれない日に回ってきた番は、使ったことにすること", async () => {
    await group.collection("dayduty_records").add({
      created_by: "teacher",
      created_at: new Date(),
      ops: [{ date: "2026-12-02", kind: "skip", member: "C", turn: 0 }],
    });
    // 2026-12-03 は木曜
    await group.collection("dayduty_rules").add({ member: "A", weekdays: [4] });
    await finalizeDayduty(GROUP_ID, "2026-12-01");

    await finalizeDayduty(GROUP_ID, "2026-12-04");

    expect(await membersOf()).toEqual(["B", "D", "B", "C"]);
  });

  it("名簿に入った人は、最初に確定した日にいる人の最大の数で書くこと", async () => {
    await finalizeDayduty(GROUP_ID, "2026-12-01");
    await addStudent("E", 5);

    await finalizeDayduty(GROUP_ID, "2026-12-08");

    expect((await finalizedDays())[1]).toEqual({
      date: "2026-12-02",
      members: ["C"],
      turns: { C: 1, E: 1 },
    });
    expect(await membersOf()).toEqual(["B", "C", "D", "A", "B", "C", "D", "E"]);
  });

  it.each([
    [
      "出席番号が欠けている",
      async () => {
        await firestore.collection("classmates").doc("C").delete();
        await addStudent("E", 5);
      },
    ],
    [
      "出席番号のない生徒がいる",
      async () => {
        await firestore.collection("classmates").doc("E").set({
          group_id: GROUP_ID,
          role: "student",
          name: "E",
          slackUserId: "E",
        });
      },
    ],
  ])(
    "%s グループは、今の式と同じ順にならないので決めないこと",
    async (_, arrange) => {
      await arrange();

      await expect(finalizeDayduty(GROUP_ID, "2026-12-01")).rejects.toThrow(
        DaydutyNotConfiguredError,
      );
      expect(await finalizedDays()).toEqual([]);
    },
  );

  it("開始日より前の日は、決めないこと", async () => {
    await expect(finalizeDayduty(GROUP_ID, "2026-11-26")).rejects.toThrow(
      "日直の開始日より前です",
    );
  });

  it("開始日がないグループは、決められないことを知らせること", async () => {
    await group.set({ name: "Test Group" });

    await expect(finalizeDayduty(GROUP_ID, "2026-12-01")).rejects.toThrow(
      DaydutyNotConfiguredError,
    );
  });
});

describe("finalizeAllDayduty", () => {
  beforeEach(async () => {
    await group.set({ name: "Test Group", dayduty_start_date: "2026-11-30" });
    await addStudent("A", 1);
    await addStudent("B", 2);
    await firestore
      .collection("groups")
      .doc("test_group_not_configured")
      .set({ name: "No start date" });
    await firestore
      .collection("groups")
      .doc("test_group_broken")
      .set({ name: "Broken", dayduty_start_date: "invalid" });
    await firestore.collection("classmates").doc("X").set({
      group_id: "test_group_broken",
      role: "student",
      stuNo: 1,
      name: "X",
      slackUserId: "X",
    });

    return async () => {
      for (const id of [
        GROUP_ID,
        "test_group_not_configured",
        "test_group_broken",
      ]) {
        await firestore.collection("groups").doc(id).delete();
      }
      for (const id of ["A", "B", "X"]) {
        await firestore.collection("classmates").doc(id).delete();
      }
      // ほかのテストが残したグループにも書くので、すべてのグループから消す
      await deleteCollection(firestore.collectionGroup("dayduty_days"));
      await deleteCollection(firestore.collectionGroup("dayduty_members"));
    };
  });

  it("日本時間の昨日までを確定し、開始日がないか形の崩れたグループは飛ばすこと", async () => {
    // 日本時間では 2026-12-02 の 0:05
    const now = DateTime.fromISO("2026-12-01T15:05:00Z");

    const failed = await finalizeAllDayduty(now);

    expect(failed).not.toContain(GROUP_ID);
    expect(failed).not.toContain("test_group_not_configured");
    expect(failed).not.toContain("test_group_broken");

    expect(await finalizedDays()).toEqual([
      { date: "2026-12-01", members: ["B"], turns: { A: 1, B: 1 } },
    ]);
  });
  it("確定できなかったグループを返し、ほかのグループは確定すること", async () => {
    await firestore
      .collection("groups")
      .doc("test_group_broken")
      .collection("dayduty_days")
      .doc("2026-00-01")
      .set({ date: "2026-00-01", members: [], turns: {} });

    const failed = await finalizeAllDayduty(
      DateTime.fromISO("2026-12-01T15:05:00Z"),
    );

    expect(failed).toContain("test_group_broken");
    expect(await membersOf()).toEqual(["B"]);
  });
});
