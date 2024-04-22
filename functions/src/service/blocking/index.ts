import { getFirestore } from "firebase-admin/firestore";
import { beforeUserCreated } from "firebase-functions/v2/identity";

export const beforeUserCreate = beforeUserCreated(
  {
    region: "asia-northeast1",
  },
  async (event) => {
    const user = event.data;

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
  },
);
