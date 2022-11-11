import { getFirestore } from "firebase-admin/firestore";
import { region } from "firebase-functions";

export const beforeCreate = region("asia-northeast1")
  .auth.user()
  .beforeCreate(async (user, _context) => {
    const snapshot = await getFirestore()
      .doc("environment/allowed_emails")
      .get();

    // FIXME: wow
    const isAllowedUser = (
      snapshot.data as any as { value: string[] }
    ).value.every((pattern) => {
      return user.email && RegExp(pattern).test(user.email);
    });
    if (!isAllowedUser) {
      throw new Error("Invalid user.");
    }

    return;
  });
