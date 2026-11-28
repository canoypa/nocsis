import { beforeEach, describe, expect, it } from "vitest";
import { firestore } from "../clients/firebase.js";
import { getDayduty } from "./dayduty_service.js";

const GROUP_ID = "test_group_1";
const group = firestore.collection("groups").doc(GROUP_ID);

const deleteCollection = async (
  ref: FirebaseFirestore.Query<FirebaseFirestore.DocumentData>,
) => {
  const snapshot = await ref.get();
  const batch = firestore.batch();
  for (const doc of snapshot.docs) batch.delete(doc.ref);
  await batch.commit();
};

const namesOf = (days: Awaited<ReturnType<typeof getDayduty>>) =>
  days.map((day) => day.members.map((m) => m.name).join(""));

describe("getDayduty", () => {
  beforeEach(async () => {
    await group.set({ name: "Test Group", dayduty_start_date: "2025-01-01" });

    // 出席番号順に並べるのを確かめるため、順不同で入れる
    for (const [stuNo, name] of [
      [3, "C"],
      [1, "A"],
      [4, "D"],
      [2, "B"],
    ] as const) {
      await firestore.collection("classmates").doc(name).set({
        group_id: GROUP_ID,
        role: "student",
        stuNo,
        name,
        slackUserId: name,
      });
    }
    await firestore.collection("classmates").doc("T").set({
      group_id: GROUP_ID,
      role: "teacher",
      stuNo: 99,
      name: "T",
      slackUserId: "T",
    });

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

  describe("確定した日がない場合", () => {
    it("開始日からの経過日数で決めていたときと同じ人が返されること", async () => {
      const days = await getDayduty(GROUP_ID, "2025-01-01", "2025-01-06");

      expect(namesOf(days)).toEqual(["A", "B", "C", "D", "A", "B"]);
    });

    it("途中の日から読んでも、同じ人が返されること", async () => {
      const days = await getDayduty(GROUP_ID, "2025-01-03", "2025-01-03");

      expect(days).toEqual([
        { date: "2025-01-03", members: [{ id: "C", name: "C" }] },
      ]);
    });

    it("開始日より前の日も、順番どおりに返されること", async () => {
      const days = await getDayduty(GROUP_ID, "2024-12-31", "2024-12-31");

      expect(namesOf(days)).toEqual(["D"]);
    });

    it("グループがなければエラーになること", async () => {
      await expect(
        getDayduty("non_existent_group", "2025-01-01", "2025-01-01"),
      ).rejects.toThrow("Group not found");
    });

    it("開始日が設定されていなければエラーになること", async () => {
      await group.set({ name: "Test Group" });

      await expect(
        getDayduty(GROUP_ID, "2025-01-01", "2025-01-01"),
      ).rejects.toThrow("dayduty_start_date is not set");
    });

    it("開始日の形が正しくなければエラーになること", async () => {
      await group.set({ name: "Test Group", dayduty_start_date: "invalid" });

      await expect(
        getDayduty(GROUP_ID, "2025-01-01", "2025-01-01"),
      ).rejects.toThrow("日直開始日のフォーマットが正しくありません");
    });

    it("生徒がいなければエラーになること", async () => {
      await deleteCollection(
        firestore.collection("classmates").where("group_id", "==", GROUP_ID),
      );

      await expect(
        getDayduty(GROUP_ID, "2025-01-01", "2025-01-01"),
      ).rejects.toThrow("No students found in group");
    });
  });

  describe("確定した日がある場合", () => {
    beforeEach(async () => {
      // 12/1 に A、12/2 に B が務めた
      await group
        .collection("dayduty_days")
        .doc("2026-12-01")
        .set({ date: "2026-12-01", members: ["A"], turns: { A: 1 } });
      await group
        .collection("dayduty_days")
        .doc("2026-12-02")
        .set({ date: "2026-12-02", members: ["B"], turns: { B: 1 } });
      for (const [id, turns] of [
        ["A", 1],
        ["B", 1],
        ["C", 0],
        ["D", 0],
      ] as const) {
        await group.collection("dayduty_members").doc(id).set({ turns });
      }
    });

    it("確定した日は書いてあるとおりに、その先は続きから返されること", async () => {
      const days = await getDayduty(GROUP_ID, "2026-12-01", "2026-12-05");

      expect(namesOf(days)).toEqual(["A", "B", "C", "D", "A"]);
    });

    it("確定した日は、名簿や開始日が変わっても変わらないこと", async () => {
      await group.set({ name: "Test Group", dayduty_start_date: "2026-12-02" });
      await firestore.collection("classmates").doc("A").update({ stuNo: 5 });

      const days = await getDayduty(GROUP_ID, "2026-12-01", "2026-12-02");

      expect(namesOf(days)).toEqual(["A", "B"]);
    });

    it("名簿から消えた人は、確定した日にも出さないこと", async () => {
      await firestore.collection("classmates").doc("A").delete();

      const days = await getDayduty(GROUP_ID, "2026-12-01", "2026-12-01");

      expect(days).toEqual([{ date: "2026-12-01", members: [] }]);
    });

    it("先生が飛ばした番は、なくなること", async () => {
      await group.collection("dayduty_records").add({
        created_by: "teacher",
        created_at: new Date(),
        ops: [{ date: "2026-12-03", kind: "skip", member: "C", turn: 0 }],
      });

      const days = await getDayduty(GROUP_ID, "2026-12-03", "2026-12-05");

      expect(namesOf(days)).toEqual(["D", "A", "B"]);
    });

    it("選ばれない日に回ってきた番は、なくなること", async () => {
      // 2026-12-03 は木曜
      await group
        .collection("dayduty_rules")
        .add({ member: "C", weekdays: [4] });

      const days = await getDayduty(GROUP_ID, "2026-12-03", "2026-12-05");

      expect(namesOf(days)).toEqual(["D", "A", "B"]);
    });

    it("読んでも何も書かないこと", async () => {
      const snapshot = async () =>
        Promise.all(
          ["dayduty_days", "dayduty_members"].map(async (sub) =>
            (await group.collection(sub).get()).docs.map((doc) => [
              doc.id,
              doc.data(),
            ]),
          ),
        );
      const before = await snapshot();

      await getDayduty(GROUP_ID, "2026-12-01", "2026-12-10");

      expect(await snapshot()).toEqual(before);
    });
  });
});
