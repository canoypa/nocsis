import { onCall } from "firebase-functions/https";

export const update = onCall(
  {
    region: "asia-northeast1",
  },
  async (request) => {
    return (await import("./update.js")).default(request);
  },
);
