import type { DocumentReference } from "firebase-admin/firestore";
import { afterEach, describe, expect, it } from "vitest";
import { firestore } from "../clients/firebase.js";
import { can } from "./check.js";
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
        role: "group_admin",
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
        role: "group_admin",
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
        role: "group_admin",
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
        role: "group_student",
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
        role: "group_student",
        resource: "group:test_group_1",
      });
      const adminRef = await addBinding({
        subject: "user:test_user_1",
        role: "group_admin",
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

  describe("ROLES に無いロール名の binding がある場合", () => {
    it("通さないこと", async () => {
      await addBinding({
        subject: "user:test_user_1",
        role: "group_teacher",
        resource: "group:test_group_1",
      });

      const decision = await can(
        user("test_user_1"),
        "group.read",
        group("test_group_1"),
      );

      expect(decision).toEqual({
        allowed: false,
        reason: "insufficient_permission",
      });
    });
  });
});
