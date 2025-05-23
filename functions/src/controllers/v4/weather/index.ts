import { HttpsError, onCall } from "firebase-functions/https";

export const now = onCall(
  {
    region: "asia-northeast1",
    secrets: ["OPENWEATHERMAP_TOKEN"],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be authenticated to use this function",
      );
    }

    const data = await import("./now.js").then((m) => m.default(request));

    return data;
  },
);
