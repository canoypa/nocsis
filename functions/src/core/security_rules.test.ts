import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import {
  assertFails,
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { afterAll, beforeAll, describe, it } from "vitest";

// firestore.rules / storage.rules は意図的に deny-all。
// クライアントは Firestore/Storage に直接アクセスせず、backend/functions は
// Admin SDK 経由でルールを迂回するため、想定される正規の経路が存在しない。
// このテストは「誰かが誤って allow を追加してしまう」回帰だけを検出する保険。

const PROJECT_ID = "class-clock-40088";
const repoRoot = fileURLToPath(new URL("../../../", import.meta.url));

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(`${repoRoot}firestore.rules`, "utf8"),
      host: "localhost",
      port: 8888,
    },
    storage: {
      rules: readFileSync(`${repoRoot}storage.rules`, "utf8"),
      host: "localhost",
      port: 9199,
    },
  });
});

afterAll(async () => {
  await testEnv?.cleanup();
});

describe("Firestore security rules (deny-all)", () => {
  it("未認証ユーザーは読み取りできない", async () => {
    const unauthed = testEnv.unauthenticatedContext();
    await assertFails(
      unauthed.firestore().collection("users").doc("alice").get(),
    );
  });

  it("認証済みユーザーでも読み取りできない", async () => {
    const authed = testEnv.authenticatedContext("alice");
    await assertFails(
      authed.firestore().collection("users").doc("alice").get(),
    );
  });

  it("認証済みユーザーでも書き込みできない", async () => {
    const authed = testEnv.authenticatedContext("alice");
    await assertFails(
      authed.firestore().collection("users").doc("alice").set({
        name: "Alice",
      }),
    );
  });
});

describe("Storage security rules (deny-all)", () => {
  it("未認証ユーザーは読み取りできない", async () => {
    const unauthed = testEnv.unauthenticatedContext();
    await assertFails(
      unauthed.storage().ref("avatars/alice.png").getDownloadURL(),
    );
  });

  it("認証済みユーザーでも書き込みできない", async () => {
    const authed = testEnv.authenticatedContext("alice");
    await assertFails(
      Promise.resolve(
        authed.storage().ref("avatars/alice.png").putString("dGVzdA=="),
      ),
    );
  });
});
