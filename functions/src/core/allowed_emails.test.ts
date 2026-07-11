import { describe, expect, it } from "vitest";
import { isAllowedEmail } from "./allowed_emails.js";

describe("isAllowedEmail", () => {
  describe("複数パターンの許可リスト", () => {
    const patterns = [
      "student@school\\.example\\.com",
      "teacher@school\\.example\\.com",
    ];

    it("いずれか 1 つのパターンに一致すれば許可する（.some の回帰）", () => {
      expect(isAllowedEmail("student@school.example.com", patterns)).toBe(
        true,
      );
      expect(isAllowedEmail("teacher@school.example.com", patterns)).toBe(
        true,
      );
    });

    it("どのパターンにも一致しなければ拒否する", () => {
      expect(isAllowedEmail("outsider@other.example.com", patterns)).toBe(
        false,
      );
    });
  });

  describe("正規表現のアンカー", () => {
    const patterns = ["[a-z]+@school\\.example\\.com"];

    it("部分一致によるバイパスを拒否する（未アンカーだと通ってしまうケース）", () => {
      expect(
        isAllowedEmail("user@school.example.com.attacker.com", patterns),
      ).toBe(false);
      expect(
        isAllowedEmail("prefix.user@school.example.com", patterns),
      ).toBe(false);
    });

    it("完全一致は許可する", () => {
      expect(isAllowedEmail("user@school.example.com", patterns)).toBe(true);
    });
  });

  describe("fail-closed", () => {
    it("patterns が undefined なら拒否する", () => {
      expect(isAllowedEmail("user@school.example.com", undefined)).toBe(
        false,
      );
    });

    it("patterns が配列でないなら拒否する", () => {
      expect(
        isAllowedEmail("user@school.example.com", "not-an-array"),
      ).toBe(false);
    });

    it("patterns が空配列なら拒否する", () => {
      expect(isAllowedEmail("user@school.example.com", [])).toBe(false);
    });

    it("email が無ければ拒否する", () => {
      expect(
        isAllowedEmail(undefined, ["[a-z]+@school\\.example\\.com"]),
      ).toBe(false);
    });

    it("不正な正規表現パターンが含まれる場合は拒否する（他のパターンが有効でも通さない）", () => {
      const patterns = ["user@school\\.example\\.com", "(unbalanced["];
      expect(isAllowedEmail("user@school.example.com", patterns)).toBe(
        false,
      );
    });

    it("文字列でないパターンが含まれる場合は拒否する", () => {
      const patterns = ["user@school\\.example\\.com", 123];
      expect(isAllowedEmail("user@school.example.com", patterns)).toBe(
        false,
      );
    });
  });
});
