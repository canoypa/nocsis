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

    const data = snapshot.data();
    const patterns = data?.value;

    // 許可リストが取得できない・空・不正な場合は fail-closed で拒否する
    if (!Array.isArray(patterns) || patterns.length === 0) {
      throw new Error("Invalid user.");
    }

    const email = user.email;

    // いずれかのパターンに一致すれば許可（部分一致を避けるため完全一致にアンカーする）
    const isAllowedUser =
      !!email &&
      patterns.some((pattern) => {
        if (typeof pattern !== "string") {
          return false;
        }
        return new RegExp(`^(?:${pattern})$`).test(email);
      });
    if (!isAllowedUser) {
      throw new Error("Invalid user.");
    }

    return;
  },
);
