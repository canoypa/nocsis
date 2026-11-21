import type { DocumentReference } from "firebase-admin/firestore";
import { afterEach, describe, expect, it } from "vitest";
import { firestore } from "../clients/firebase.js";
import { can, permissionsByResource, resourceIdsWith } from "./check.js";
import { user } from "./principal.js";
import { group } from "./resource.js";

const created: DocumentReference[] = [];

const addBinding = async (binding: {
  subject: string;
  role: string;
  resource: string;
}) => {
  const ref = await firestore.collection("role_bindings").add(binding);
  created.push(ref);

  return ref;
};

afterEach(async () => {
  await Promise.all(created.splice(0).map((ref) => ref.delete()));
});

describe("can", () => {
  describe("binding が1つも無い場合", () => {
    it("no_binding で拒否すること", async () => {
      const decision = await can(
        user("test_user_1"),
        "group.read",
        group("test_group_1"),
      );

      expect(decision).toEqual({ allowed: false, reason: "no_binding" });
    });
  });

  describe("別のリソースにしか binding が無い場合", () => {
    it("no_binding で拒否すること", async () => {
      await addBinding({
        subject: "user:test_user_1",
        role: "roles/group.admin",
        resource: "group:test_group_2",
      });

      const decision = await can(
        user("test_user_1"),
        "group.read",
        group("test_group_1"),
      );

      expect(decision).toEqual({ allowed: false, reason: "no_binding" });
    });
  });

  describe("別の主体にしか binding が無い場合", () => {
    it("no_binding で拒否すること", async () => {
      await addBinding({
        subject: "user:test_user_2",
        role: "roles/group.admin",
        resource: "group:test_group_1",
      });

      const decision = await can(
        user("test_user_1"),
        "group.read",
        group("test_group_1"),
      );

      expect(decision).toEqual({ allowed: false, reason: "no_binding" });
    });
  });

  describe("permission を含むロールの binding がある場合", () => {
    it("どの binding で通ったかを添えて許可すること", async () => {
      const ref = await addBinding({
        subject: "user:test_user_1",
        role: "roles/group.admin",
        resource: "group:test_group_1",
      });

      const decision = await can(
        user("test_user_1"),
        "group.update",
        group("test_group_1"),
      );

      expect(decision).toEqual({
        allowed: true,
        via: `role_bindings/${ref.id}`,
      });
    });
  });

  describe("binding はあるが permission が足りない場合", () => {
    it("insufficient_permission で拒否すること", async () => {
      await addBinding({
        subject: "user:test_user_1",
        role: "roles/group.viewer",
        resource: "group:test_group_1",
      });

      const decision = await can(
        user("test_user_1"),
        "group.update",
        group("test_group_1"),
      );

      expect(decision).toEqual({
        allowed: false,
        reason: "insufficient_permission",
      });
    });
  });

  describe("複数の binding がある場合", () => {
    it("いずれかが permission を含めば許可すること", async () => {
      await addBinding({
        subject: "user:test_user_1",
        role: "roles/group.viewer",
        resource: "group:test_group_1",
      });
      const adminRef = await addBinding({
        subject: "user:test_user_1",
        role: "roles/group.admin",
        resource: "group:test_group_1",
      });

      const decision = await can(
        user("test_user_1"),
        "group.update",
        group("test_group_1"),
      );

      expect(decision).toEqual({
        allowed: true,
        via: `role_bindings/${adminRef.id}`,
      });
    });
  });

  describe("ROLES に無いロール名の binding しか無い場合", () => {
    // 何も付与していない行なので、リソースの存在を知る根拠にもならない
    it("binding が無いのと同じ扱いになること", async () => {
      await addBinding({
        subject: "user:test_user_1",
        role: "roles/group.teacher",
        resource: "group:test_group_1",
      });

      const decision = await can(
        user("test_user_1"),
        "group.read",
        group("test_group_1"),
      );

      expect(decision).toEqual({ allowed: false, reason: "no_binding" });
    });
  });

  describe("ROLES に無いロール名の binding が混ざっている場合", () => {
    it("有効な binding の方で判定すること", async () => {
      await addBinding({
        subject: "user:test_user_1",
        role: "roles/group.teacher",
        resource: "group:test_group_1",
      });
      await addBinding({
        subject: "user:test_user_1",
        role: "roles/group.viewer",
        resource: "group:test_group_1",
      });

      const decision = await can(
        user("test_user_1"),
        "group.update",
        group("test_group_1"),
      );

      expect(decision).toEqual({
        allowed: false,
        reason: "insufficient_permission",
      });
    });
  });
});

describe("permissionsByResource", () => {
  it("リソースごとに、ロールの permission の和を PERMISSIONS の順で返すこと", async () => {
    await addBinding({
      subject: "user:test_user_1",
      role: "roles/group.display",
      resource: "group:test_group_1",
    });
    await addBinding({
      subject: "user:test_user_1",
      role: "roles/group.viewer",
      resource: "group:test_group_1",
    });
    await addBinding({
      subject: "user:test_user_1",
      role: "roles/group.viewer",
      resource: "group:test_group_2",
    });

    const granted = await permissionsByResource(user("test_user_1"), "group");

    expect(granted).toEqual(
      new Map([
        ["test_group_1", ["group.read", "member.read"]],
        ["test_group_2", ["group.read"]],
      ]),
    );
  });

  it("定義に無いロール、別の主体、壊れた resource の行は数えないこと", async () => {
    await addBinding({
      subject: "user:test_user_1",
      role: "roles/group.teacher",
      resource: "group:test_group_1",
    });
    await addBinding({
      subject: "user:test_user_2",
      role: "roles/group.admin",
      resource: "group:test_group_1",
    });
    await addBinding({
      subject: "user:test_user_1",
      role: "roles/group.admin",
      resource: "group:",
    });
    await addBinding({
      subject: "user:test_user_1",
      role: "roles/group.admin",
      resource: "group:a/b",
    });

    const granted = await permissionsByResource(user("test_user_1"), "group");

    expect(granted).toEqual(new Map());
  });
});

describe("resourceIdsWith", () => {
  it("permission を含むリソースの ID だけを返すこと", async () => {
    await addBinding({
      subject: "user:test_user_1",
      role: "roles/group.admin",
      resource: "group:test_group_1",
    });
    await addBinding({
      subject: "user:test_user_1",
      role: "roles/group.viewer",
      resource: "group:test_group_2",
    });

    const ids = await resourceIdsWith(
      user("test_user_1"),
      "group.update",
      "group",
    );

    expect(ids).toEqual(["test_group_1"]);
  });
});
