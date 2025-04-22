import { HttpsError, onCall } from "firebase-functions/https";

export const get = onCall(
  {
    region: "asia-northeast1",
  },
  async (request) => {
    const auth = request.auth;

    if (!auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be authenticated to use this function",
      );
    }

    const data = await import("./get.js").then((m) =>
      m.default({ user_id: auth.uid }),
    );

    return data;
  },
);
