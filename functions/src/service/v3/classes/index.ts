import { HttpsError, onCall } from "firebase-functions/v2/https";

export const get = onCall(
  {
    region: "asia-northeast1",
    secrets: ["CALENDAR_ACCOUNT_KEY"],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be authenticated to use this function",
      );
    }

    return (await import("./get.js"))
      .default(request.data)
      .catch(console.error);
  },
);
