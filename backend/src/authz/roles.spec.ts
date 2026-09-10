import { describe, expect, it } from "vitest";
import { isRoleName, PERMISSIONS, permissionsOf, ROLES } from "./roles.js";

describe("roles", () => {
  describe("ROLES", () => {
    // 「binding があるのに read できない」ロールが存在すると、404 と 403 の判定
    // （authz/middleware.ts）が「binding の有無」だけでは正しくなくなる
    it("すべてのロールがそのスコープの read 権限を含むこと", () => {
      for (const role of Object.values(ROLES)) {
        expect(role.permissions).toContain(`${role.scope}.read`);
      }
    });

    it("知らない permission を宣言しているロールが無いこと", () => {
      for (const role of Object.values(ROLES)) {
        for (const permission of role.permissions) {
          expect(PERMISSIONS).toContain(permission);
        }
      }
    });
  });

  describe("isRoleName", () => {
    it("定義済みのロール名を受け入れること", () => {
      expect(isRoleName("group_admin")).toBe(true);
    });

    it("定義に無い名前を受け入れないこと", () => {
      expect(isRoleName("group_teacher")).toBe(false);
    });

    it("Object のプロパティ名を受け入れないこと", () => {
      expect(isRoleName("toString")).toBe(false);
    });

    it("文字列でない値を受け入れないこと", () => {
      expect(isRoleName(undefined)).toBe(false);
    });
  });

  describe("permissionsOf", () => {
    it("ロールの permission を返すこと", () => {
      expect(permissionsOf("group_student")).toEqual(["group.read"]);
    });
  });
});
