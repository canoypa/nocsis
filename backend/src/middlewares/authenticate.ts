import assert from "node:assert";
import type { Context } from "hono";
import { bearerAuth } from "hono/bearer-auth";
import { auth } from "../clients/firebase.js";

export type AuthenticatedEnv = {
  Variables: {
    currentUserId: string;
  };
};

export const authentication = bearerAuth({
  verifyToken: async (token, c) => {
    try {
      const { uid } = await auth.verifyIdToken(token);

      c.set("currentUserId", uid);
    } catch (err) {
      if (
        process.env.NODE_ENV === "development" ||
        process.env.NODE_ENV === "production"
      ) {
        console.warn("ユーザー認証でエラー発生: ", err);
      }

      return false;
    }

    return true;
  },
});

export const getCurrentUserId = (c: Context<AuthenticatedEnv>): string => {
  const uid = c.get("currentUserId");
  assert(uid);

  return uid;
};
