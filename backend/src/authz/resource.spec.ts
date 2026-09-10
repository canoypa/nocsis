import { describe, expect, it } from "vitest";
import { ancestors, group, serialize } from "./resource.js";

describe("resource", () => {
  describe("group", () => {
    it("グループのリソース参照を作れること", () => {
      expect(group("xyz")).toEqual({ type: "group", id: "xyz" });
    });
  });

  describe("serialize", () => {
    it("role_bindings.resource の表現になること", () => {
      expect(serialize(group("xyz"))).toBe("group:xyz");
    });
  });

  describe("ancestors", () => {
    it("自分自身を含むこと", () => {
      expect(ancestors(group("xyz"))).toEqual([group("xyz")]);
    });
  });
});
