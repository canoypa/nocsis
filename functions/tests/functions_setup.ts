import firebaseFunctionsTest from "firebase-functions-test";
import { afterAll, afterEach } from "vitest";

const PROJECT_ID = "class-clock-40088";

export const functionsTest = firebaseFunctionsTest({
  projectId: PROJECT_ID,
});

process.env.FIRESTORE_EMULATOR_HOST = "localhost:8080";

afterEach(async () => {
  await fetch(
    `http://${process.env.FIRESTORE_EMULATOR_HOST}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`,
    { method: "DELETE" },
  );
});

afterAll(() => {
  functionsTest.cleanup();
});
