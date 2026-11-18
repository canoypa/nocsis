import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { firestore } from "../clients/firebase.js";
import { backfillFromJoinedGroups } from "./backfill.js";
import { COLLECTION } from "./binding.js";

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

describe("backfillFromJoinedGroups", () => {
  it("参加1件ごとに viewer の binding を作ること", async () => {
    await memberships.add({ user_id: "u1", group_id: "g1" });
    await memberships.add({ user_id: "u1", group_id: "g2" });
    await memberships.add({ user_id: "u2", group_id: "g1" });

    const result = await backfillFromJoinedGroups();

    expect(result).toEqual({
      rows: 3,
      created: 3,
      alreadyGranted: 0,
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

    const result = await backfillFromJoinedGroups();

    expect(result).toEqual({
      rows: 2,
      created: 1,
      alreadyGranted: 1,
      skipped: 0,
    });
    expect(await triples()).toEqual(["user:u1 roles/group.viewer group:g1"]);
  });

  it("もう一度流しても増えないこと", async () => {
    await memberships.add({ user_id: "u1", group_id: "g1" });

    await backfillFromJoinedGroups();
    const result = await backfillFromJoinedGroups();

    expect(result).toEqual({
      rows: 1,
      created: 0,
      alreadyGranted: 1,
      skipped: 0,
    });
    expect(await triples()).toHaveLength(1);
  });

  it("user_id か group_id が欠けた行は飛ばすこと", async () => {
    await memberships.add({ user_id: "u1" });
    await memberships.add({ group_id: "g1" });
    await memberships.add({ user_id: "", group_id: "g1" });
    await memberships.add({ user_id: 1, group_id: "g1" });

    const result = await backfillFromJoinedGroups();

    expect(result).toEqual({
      rows: 4,
      created: 0,
      alreadyGranted: 0,
      skipped: 4,
    });
    expect(await triples()).toEqual([]);
  });

  it("user_joined_groups を消さないこと", async () => {
    await memberships.add({ user_id: "u1", group_id: "g1" });

    await backfillFromJoinedGroups();

    expect((await memberships.get()).size).toBe(1);
  });
});
