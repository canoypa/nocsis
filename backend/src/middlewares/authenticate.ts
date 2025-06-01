import { type UserRecord, getAuth } from "firebase-admin/auth";
import { bearerAuth } from "hono/bearer-auth";
import { firebaseApp } from "../clients/firebase_app.js";

export type AuthenticatedEnv = {
  Variables: {
    currentUser: UserRecord;
  };
};

export const authentication = bearerAuth({
  verifyToken: async (token, c) => {
    try {
      const auth = getAuth(firebaseApp);
      const { uid } = await auth.verifyIdToken(token);
      const user = await auth.getUser(uid);

      c.set("currentUser", user);
    } catch (err) {
      console.warn("ユーザー認証でエラー発生: ", err);
      return false;
    }

    return true;
  },
});
