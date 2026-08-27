import { describe, expect, it } from "vitest";
import { subject, user } from "./principal.js";

describe("principal", () => {
  describe("user", () => {
    it("uid から user 主体を作れること", () => {
      expect(user("abc")).toEqual({ kind: "user", uid: "abc" });
    });
  });

  describe("subject", () => {
    it("role_bindings.subject の表現になること", () => {
      expect(subject(user("abc"))).toBe("user:abc");
    });
  });
});
