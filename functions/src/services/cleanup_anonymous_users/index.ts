import { getAuth, type UserRecord } from "firebase-admin/auth";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import type { DateTime } from "luxon";
import { firebaseApp } from "~/client/firebaseApp.js";

const UNUSED_DAYS = 30;

/**
 * 30日以上使われていない匿名アカウントを、付与ごと消す。
 * 教室ディスプレイとして登録されていた端末は、一覧に「解除された」と残す。
 */
export const cleanupAnonymousUsers = async (now: DateTime): Promise<void> => {
  const auth = getAuth(firebaseApp);
  const cutoff = now.minus({ days: UNUSED_DAYS }).toMillis();

  const stale: string[] = [];
  let pageToken: string | undefined;
  do {
    const page = await auth.listUsers(1000, pageToken);
    for (const user of page.users) {
      if (isAnonymous(user) && lastUsedAt(user) < cutoff) stale.push(user.uid);
    }
    pageToken = page.pageToken;
  } while (pageToken);

  for (const uid of stale) {
    await revokeAll(uid, Timestamp.fromMillis(now.toMillis()));
  }

  // 付与を先に外す。逆だと、消えたアカウントの付与だけが残る
  for (let i = 0; i < stale.length; i += 1000) {
    await auth.deleteUsers(stale.slice(i, i + 1000));
  }
};

const isAnonymous = (user: UserRecord) =>
  user.providerData.length === 0 && !user.email && !user.phoneNumber;

/** トークンを更新した時刻。表示中の端末は1時間ごとに更新する */
const lastUsedAt = (user: UserRecord) =>
  Date.parse(
    user.metadata.lastRefreshTime ??
      user.metadata.lastSignInTime ??
      user.metadata.creationTime,
  );

const revokeAll = async (uid: string, removedAt: Timestamp) => {
  const firestore = getFirestore(firebaseApp);
  const bindings = await firestore
    .collection("role_bindings")
    .where("subject", "==", `user:${uid}`)
    .get();

  const batch = firestore.batch();
  for (const binding of bindings.docs) {
    batch.delete(binding.ref);

    const resource: string = binding.get("resource");
    if (
      binding.get("role") !== "roles/group.display" ||
      !resource.startsWith("group:")
    ) {
      continue;
    }

    const display = firestore
      .collection("groups")
      .doc(resource.slice("group:".length))
      .collection("displays")
      .doc(uid);
    if ((await display.get()).exists) {
      batch.update(display, { removed_at: removedAt });
    }
  }
  await batch.commit();
};

export default cleanupAnonymousUsers;
