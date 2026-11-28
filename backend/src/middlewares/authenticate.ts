import assert from "node:assert";

import type { Context } from "hono";
import { bearerAuth } from "hono/bearer-auth";

import { auth } from "../clients/firebase.js";

export type AuthenticatedEnv = {
  Variables: {
    currentUserId: string;
    signInProvider: string;
    /** 最後にログイン (再認証を含む) した時刻。UNIX 秒 */
    authTime: number;
  };
};

export const authentication = bearerAuth({
  verifyToken: async (token, c: Context<AuthenticatedEnv>) => {
    try {
      const { uid, firebase, auth_time } = await auth.verifyIdToken(token);

      c.set("currentUserId", uid);
      c.set("signInProvider", firebase.sign_in_provider);
      c.set("authTime", auth_time);
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
