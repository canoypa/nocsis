import { region } from "firebase-functions";

export const now = region("asia-northeast1")
  .runWith({
    memory: "512MB",
    secrets: ["OPENWEATHERMAP_TOKEN", "SWITCHBOT_TOKEN"],
  })
  .https.onCall(async (...args) => {
    return (await import("./now")).default(...args).catch(console.error);
  });
