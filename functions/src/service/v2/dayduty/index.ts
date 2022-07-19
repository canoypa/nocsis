import { region } from "firebase-functions";

export const get = region("asia-northeast1")
  .runWith({
    memory: "512MB",
  })
  .https.onCall(async (...args) => {
    return (await import("./get")).default(...args).catch(console.error);
  });
