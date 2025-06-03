import type { UserRecord } from "firebase-admin/auth";
import { z } from "zod";
import { auth } from "../../src/clients/firebase.js";

const LoginResultSchema = z.object({
  idToken: z.string(),
  refreshToken: z.string(),
  expiresIn: z.string(),
});
export type LoginResult = z.infer<typeof LoginResultSchema>;

export const login = async (user: UserRecord) => {
  const customToken = await auth.createCustomToken(user.uid);

  const res = await fetch(
    "http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=dummy",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        token: customToken,
        returnSecureToken: true,
      }),
    },
  ).then((res) => res.json());

  const parsed = LoginResultSchema.safeParse(res);
  if (!parsed.success) {
    throw new Error("Failed to parse login response");
  }

  return parsed.data;
};
