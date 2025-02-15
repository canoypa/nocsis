import { HttpsError, onCall } from "firebase-functions/https";

export const now = onCall(
  {
    region: "asia-northeast1",
    secrets: ["OPENWEATHERMAP_TOKEN", "SWITCHBOT_TOKEN"],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be authenticated to use this function",
      );
    }

    return (await import("./now.js")).default().catch(console.error);
  },
);
