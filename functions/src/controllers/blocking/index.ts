import { getFirestore } from "firebase-admin/firestore";
import { beforeUserCreated } from "firebase-functions/identity";
import { firebaseApp } from "~/client/firebaseApp.js";

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

    const data = snapshot.data() as { value: string[] };

    // FIXME: wow
    const isAllowedUser = data.value.every((pattern) => {
      return user.email && RegExp(pattern).test(user.email);
    });
    if (!isAllowedUser) {
      throw new Error("Invalid user.");
    }

    return;
  },
);
