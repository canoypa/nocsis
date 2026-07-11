import { getFirestore } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { functionsTest } from "../../../tests/functions_setup.js";
import { beforeUserCreate } from "./index.js";

const wrapped = functionsTest.wrap(beforeUserCreate);

const setAllowedEmails = async (value: unknown) => {
  await getFirestore(firebaseApp).doc("environment/allowed_emails").set({ value });
};

// biome-ignore lint/suspicious/noExplicitAny: firebase-functions-test の blocking イベント型が緩いため
const callWith = (email?: string) => wrapped({ data: { email } } as any);

describe("beforeUserCreate", () => {
  describe("複数パターンの許可リスト", () => {
    beforeEach(async () => {
      await setAllowedEmails(["student@school\\.example\\.com", "teacher@school\\.example\\.com"]);
    });

    it("いずれか 1 つのパターンに一致すれば許可する（.some の回帰）", async () => {
      await expect(callWith("student@school.example.com")).resolves.not.toThrow();
      await expect(callWith("teacher@school.example.com")).resolves.not.toThrow();
    });

    it("どのパターンにも一致しなければ拒否する", async () => {
      await expect(callWith("outsider@other.example.com")).rejects.toThrow("Invalid user.");
    });
  });

  describe("正規表現のアンカー", () => {
    beforeEach(async () => {
      await setAllowedEmails(["[a-z]+@school\\.example\\.com"]);
    });

    it("部分一致によるバイパスを拒否する（未アンカーだと通ってしまうケース）", async () => {
      await expect(
        callWith("user@school.example.com.attacker.com"),
      ).rejects.toThrow("Invalid user.");
      await expect(
        callWith("prefix.user@school.example.com"),
      ).rejects.toThrow("Invalid user.");
    });

    it("完全一致は許可する", async () => {
      await expect(callWith("user@school.example.com")).resolves.not.toThrow();
    });
  });

  describe("fail-closed", () => {
    it("許可リスト文書が存在しなければ拒否する", async () => {
      await expect(callWith("user@school.example.com")).rejects.toThrow("Invalid user.");
    });

    it("許可リストが空配列なら拒否する", async () => {
      await setAllowedEmails([]);
      await expect(callWith("user@school.example.com")).rejects.toThrow("Invalid user.");
    });

    it("email が無いユーザーは拒否する", async () => {
      await setAllowedEmails(["[a-z]+@school\\.example\\.com"]);
      await expect(callWith(undefined)).rejects.toThrow("Invalid user.");
    });
  });
});
