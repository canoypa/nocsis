import { region } from "firebase-functions";

export const get = region("asia-northeast1")
  .runWith({
    memory: "512MB",
    secrets: ["CALENDAR_ACCOUNT_KEY"],
  })
  .https.onCall(async (...args) => {
    return (await import("./get")).default(...args).catch(console.error);
  });
