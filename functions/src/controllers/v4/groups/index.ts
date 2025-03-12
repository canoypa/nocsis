import { onCall } from "firebase-functions/https";

export * as user_joined_groups from "./user_joined_groups/index.js";

export const update = onCall(
  {
    region: "asia-northeast1",
  },
  async (request) => {
    return (await import("./update.js")).default(request);
  },
);
