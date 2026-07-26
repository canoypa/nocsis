import { getFirestore } from "firebase-admin/firestore";
import { beforeUserCreated } from "firebase-functions/identity";
import { firebaseApp } from "~/client/firebaseApp.js";
import { isAllowedEmail } from "~/core/allowed_emails.js";

export const beforeUserCreate = beforeUserCreated(
  {
    region: "asia-northeast1",
  },
  async (event) => {
    const user = event.data;

    if (!user) {
      throw new Error("User not found.");
    }

    const snapshot = await getFirestore(firebaseApp)
      .doc("environment/allowed_emails")
      .get();

    const patterns = snapshot.data()?.values;

    if (!isAllowedEmail(user.email, patterns)) {
      throw new Error("Invalid user.");
    }

    return;
  },
);
