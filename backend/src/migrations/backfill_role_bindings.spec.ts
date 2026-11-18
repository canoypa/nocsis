import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { COLLECTION } from "../authz/binding.js";
import { firestore } from "../clients/firebase.js";
import { backfillRoleBindings } from "./backfill_role_bindings.js";

const bindings = firestore.collection(COLLECTION);
const memberships = firestore.collection("user_joined_groups");

const clear = async () => {
  const snapshots = await Promise.all([bindings.get(), memberships.get()]);

  await Promise.all(
    snapshots.flatMap((s) => s.docs).map((doc) => doc.ref.delete()),
  );
};

// ほかの spec が残した参加を数えないよう、前にも消す
beforeEach(clear);
afterEach(clear);

const triples = async () =>
  (await bindings.get()).docs
    .map(
      (doc) =>
        `${doc.get("subject")} ${doc.get("role")} ${doc.get("resource")}`,
    )
    .sort();

describe("backfillRoleBindings", () => {
  it("参加1件ごとに viewer の binding を作ること", async () => {
    await memberships.add({ user_id: "u1", group_id: "g1" });
    await memberships.add({ user_id: "u1", group_id: "g2" });
    await memberships.add({ user_id: "u2", group_id: "g1" });

    const result = await backfillRoleBindings({ apply: true });

    expect(result).toEqual({
      rows: 3,
      created: 3,
      already_granted: 0,
      skipped: 0,
    });
    expect(await triples()).toEqual([
      "user:u1 roles/group.viewer group:g1",
      "user:u1 roles/group.viewer group:g2",
      "user:u2 roles/group.viewer group:g1",
    ]);
  });

  it("同じ参加が複数行あっても binding は1つにまとまること", async () => {
    await memberships.add({ user_id: "u1", group_id: "g1" });
    await memberships.add({ user_id: "u1", group_id: "g1" });

    const result = await backfillRoleBindings({ apply: true });

    expect(result).toEqual({
      rows: 2,
      created: 1,
      already_granted: 1,
      skipped: 0,
    });
    expect(await triples()).toEqual(["user:u1 roles/group.viewer group:g1"]);
  });

  it("もう一度流しても増えないこと", async () => {
    await memberships.add({ user_id: "u1", group_id: "g1" });

    await backfillRoleBindings({ apply: true });
    const result = await backfillRoleBindings({ apply: true });

    expect(result).toEqual({
      rows: 1,
      created: 0,
      already_granted: 1,
      skipped: 0,
    });
    expect(await triples()).toHaveLength(1);
  });

  it("user_id か group_id が欠けた行は飛ばすこと", async () => {
    await memberships.add({ user_id: "u1" });
    await memberships.add({ group_id: "g1" });
    await memberships.add({ user_id: "", group_id: "g1" });
    await memberships.add({ user_id: 1, group_id: "g1" });

    const result = await backfillRoleBindings({ apply: true });

    expect(result).toEqual({
      rows: 4,
      created: 0,
      already_granted: 0,
      skipped: 4,
    });
    expect(await triples()).toEqual([]);
  });

  it("user_joined_groups を消さないこと", async () => {
    await memberships.add({ user_id: "u1", group_id: "g1" });

    await backfillRoleBindings({ apply: true });

    expect((await memberships.get()).size).toBe(1);
  });

  describe("ドライランの場合", () => {
    it("書き込まずに、作るはずの件数とあるものの件数を数えること", async () => {
      await memberships.add({ user_id: "u1", group_id: "g1" });
      await backfillRoleBindings({ apply: true });
      await memberships.add({ user_id: "u2", group_id: "g1" });
      await memberships.add({ user_id: "u3" });

      const result = await backfillRoleBindings({ apply: false });

      expect(result).toEqual({
        rows: 3,
        created: 1,
        already_granted: 1,
        skipped: 1,
      });
      expect(await triples()).toEqual(["user:u1 roles/group.viewer group:g1"]);
    });
  });
});
