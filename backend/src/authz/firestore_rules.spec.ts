import { readFileSync } from "node:fs";

import {
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  where,
} from "firebase/firestore";
import {
  afterAll,
  beforeAll,
  beforeEach,
  describe,
  expect,
  test,
} from "vitest";

const mine = {
  subject: "user:device",
  role: "roles/group.display",
  resource: "group:g1",
};
const others = {
  subject: "user:someone",
  role: "roles/group.admin",
  resource: "group:g1",
};

let env: RulesTestEnvironment;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-nocsis-rules",
    firestore: {
      rules: readFileSync(
        new URL("../../../firestore.rules", import.meta.url),
        "utf8",
      ),
      host: "localhost",
      port: 8888,
    },
  });
});

afterAll(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "role_bindings/mine"), mine);
    await setDoc(doc(db, "role_bindings/others"), others);
    await setDoc(doc(db, "groups/g1"), { name: "g1" });
  });
});

const db = (uid?: string) =>
  (uid
    ? env.authenticatedContext(uid)
    : env.unauthenticatedContext()
  ).firestore();

describe("role_bindings", () => {
  test("自分の付与は、1件でも絞り込んだ一覧でも読める", async () => {
    await expect(
      getDoc(doc(db("device"), "role_bindings/mine")),
    ).resolves.toBeDefined();
    await expect(
      getDocs(
        query(
          collection(db("device"), "role_bindings"),
          where("subject", "==", "user:device"),
        ),
      ),
    ).resolves.toBeDefined();
  });

  test("他人の付与は読めない", async () => {
    await expect(
      getDoc(doc(db("device"), "role_bindings/others")),
    ).rejects.toMatchObject({ code: "permission-denied" });
    await expect(
      getDocs(
        query(
          collection(db("device"), "role_bindings"),
          where("subject", "==", "user:someone"),
        ),
      ),
    ).rejects.toMatchObject({ code: "permission-denied" });
  });

  test("絞り込まない一覧は読めない", async () => {
    await expect(
      getDocs(collection(db("device"), "role_bindings")),
    ).rejects.toMatchObject({ code: "permission-denied" });
  });

  test("サインインしていなければ読めない", async () => {
    await expect(getDoc(doc(db(), "role_bindings/mine"))).rejects.toMatchObject(
      { code: "permission-denied" },
    );
  });

  test("自分の付与でも書き換え・削除・作成はできない", async () => {
    await expect(
      setDoc(doc(db("device"), "role_bindings/mine"), {
        ...mine,
        role: "roles/group.admin",
      }),
    ).rejects.toMatchObject({ code: "permission-denied" });
    await expect(
      deleteDoc(doc(db("device"), "role_bindings/mine")),
    ).rejects.toMatchObject({ code: "permission-denied" });
    await expect(
      setDoc(doc(db("device"), "role_bindings/new"), {
        ...mine,
        resource: "group:g2",
      }),
    ).rejects.toMatchObject({ code: "permission-denied" });
  });
});

test("ほかのコレクションは読み書きできない", async () => {
  await expect(getDoc(doc(db("device"), "groups/g1"))).rejects.toMatchObject({
    code: "permission-denied",
  });
  await expect(
    setDoc(doc(db("device"), "groups/g2"), { name: "g2" }),
  ).rejects.toMatchObject({ code: "permission-denied" });
});
