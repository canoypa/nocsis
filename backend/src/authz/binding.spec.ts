import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { firestore } from "../clients/firebase.js";
import { bindingId, COLLECTION, grant, revoke } from "./binding.js";
import { user } from "./principal.js";
import { group } from "./resource.js";

const bindings = firestore.collection(COLLECTION);

const clear = async () => {
  const snapshot = await bindings.get();

  await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
};

// 件数を数えるテストがあるので、前に残った binding も消す
beforeEach(clear);
afterEach(clear);

describe("bindingId", () => {
  it("3つ組が同じなら同じ ID になること", () => {
    expect(bindingId("user:u1", "roles/group.admin", "group:g1")).toBe(
      bindingId("user:u1", "roles/group.admin", "group:g1"),
    );
  });

  it("3つ組が違えば違う ID になること", () => {
    const id = bindingId("user:u1", "roles/group.admin", "group:g1");

    expect(bindingId("user:u2", "roles/group.admin", "group:g1")).not.toBe(id);
    expect(bindingId("user:u1", "roles/group.viewer", "group:g1")).not.toBe(id);
    expect(bindingId("user:u1", "roles/group.admin", "group:g2")).not.toBe(id);
  });
});

describe("grant", () => {
  it("3つ組を保存すること", async () => {
    const result = await grant({
      principal: user("test_user_1"),
      role: "roles/group.admin",
      resource: group("test_group_1"),
    });

    expect(result).toBe("created");

    const doc = await bindings
      .doc(
        bindingId(
          "user:test_user_1",
          "roles/group.admin",
          "group:test_group_1",
        ),
      )
      .get();

    expect(doc.exists).toBe(true);
    expect(doc.data()).toEqual({
      subject: "user:test_user_1",
      role: "roles/group.admin",
      resource: "group:test_group_1",
      created_at: expect.anything(),
    });
  });

  describe("同じ付与を2回実行した場合", () => {
    it("行が増えず created_at も書き換わらないこと", async () => {
      const params = {
        principal: user("test_user_1"),
        role: "roles/group.viewer",
        resource: group("test_group_1"),
      } as const;

      expect(await grant(params)).toBe("created");

      const created = await bindings.get();
      const createdAt = created.docs[0].data().created_at;

      expect(await grant(params)).toBe("already_granted");

      const after = await bindings.get();

      expect(after.size).toBe(1);
      expect(after.docs[0].data().created_at).toEqual(createdAt);
    });
  });

  describe("ロールの scope とリソースの型が食い違う場合", () => {
    // 型では書けない組み合わせなので、CLI のように実行時に組み立てる経路を模す
    const grantUnchecked = grant as unknown as (params: {
      principal: ReturnType<typeof user>;
      role: string;
      resource: { type: string; id: string };
    }) => Promise<unknown>;

    it("書き込まずに失敗すること", async () => {
      await expect(
        grantUnchecked({
          principal: user("test_user_1"),
          role: "roles/group.admin",
          resource: { type: "space", id: "test_space_1" },
        }),
      ).rejects.toThrow();

      expect((await bindings.get()).empty).toBe(true);
    });
  });

  it("ID に区切りの | を含むと書き込まずに失敗すること", async () => {
    await expect(
      grant({
        principal: user("u1|roles/group.viewer|group:a"),
        role: "roles/group.viewer",
        resource: group("b"),
      }),
    ).rejects.toThrow();
    await expect(
      grant({
        principal: user("u1"),
        role: "roles/group.viewer",
        resource: group("a|roles/group.viewer|group:b"),
      }),
    ).rejects.toThrow();

    expect((await bindings.get()).empty).toBe(true);
  });
});

describe("revoke", () => {
  it("指定したロールの付与だけを消すこと", async () => {
    const principal = user("test_user_1");
    const resource = group("test_group_1");
    await grant({ principal, role: "roles/group.display", resource });
    await grant({ principal, role: "roles/group.viewer", resource });

    expect(
      await revoke({ principal, role: "roles/group.display", resource }),
    ).toBe("deleted");

    const remaining = await bindings.get();
    expect(remaining.docs.map((doc) => doc.get("role"))).toEqual([
      "roles/group.viewer",
    ]);
  });

  it("doc ID がハッシュでない行も消すこと", async () => {
    await bindings.add({
      subject: "user:test_user_1",
      role: "roles/group.display",
      resource: "group:test_group_1",
    });

    expect(
      await revoke({
        principal: user("test_user_1"),
        role: "roles/group.display",
        resource: group("test_group_1"),
      }),
    ).toBe("deleted");
    expect((await bindings.get()).empty).toBe(true);
  });

  it("付与が無ければ何も消さずに知らせること", async () => {
    expect(
      await revoke({
        principal: user("test_user_1"),
        role: "roles/group.display",
        resource: group("test_group_1"),
      }),
    ).toBe("not_granted");
  });
});
