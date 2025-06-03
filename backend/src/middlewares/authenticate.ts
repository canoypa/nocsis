import { assert } from "node:console";
import type { UserRecord } from "firebase-admin/auth";
import type { Context } from "hono";
import { bearerAuth } from "hono/bearer-auth";
import { auth } from "../clients/firebase.js";

export type AuthenticatedEnv = {
  Variables: {
    currentUser: UserRecord;
  };
};

export const authentication = bearerAuth({
  verifyToken: async (token, c) => {
    try {
      const { uid } = await auth.verifyIdToken(token);
      const user = await auth.getUser(uid);

      c.set("currentUser", user);
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

export const getUser = (c: Context<AuthenticatedEnv>): UserRecord => {
  const user = c.get("currentUser");
  assert(user);

  return user;
};
