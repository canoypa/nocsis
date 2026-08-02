import firebaseFunctionsTest from "firebase-functions-test";
import { afterAll, afterEach } from "vitest";

// エミュレータ起動時の --project に追従する。値が二重管理になると、
// SDK の書き込み先とこのファイルが消す先がずれる。
const PROJECT_ID = process.env.GCLOUD_PROJECT ?? "demo-nocsis";

export const functionsTest = firebaseFunctionsTest({
  projectId: PROJECT_ID,
});

process.env.FIRESTORE_EMULATOR_HOST = "localhost:8888";

afterEach(async () => {
  await fetch(
    `http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`,
    { method: "DELETE" },
  );
});

afterAll(() => {
  functionsTest.cleanup();
});
