import { setTimeout as sleep } from "node:timers/promises";
import { getAuth, type UserRecord } from "firebase-admin/auth";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import type { DateTime } from "luxon";
import { firebaseApp } from "~/client/firebaseApp.js";

const UNUSED_DAYS = 30;
/** getUsers が一度に受け取れる数 */
const CHUNK = 100;
/** 毎分の定期実行が既定の60秒で打ち切られる前に止める。残りは翌日に回す */
const BUDGET_MS = 40_000;

/**
 * 30日以上使われていない匿名アカウントを、付与ごと消す。
 * 教室ディスプレイとして登録されていた端末は、一覧に「解除された」と残す。
 */
export const cleanupAnonymousUsers = async (now: DateTime): Promise<void> => {
  const auth = getAuth(firebaseApp);
  const startedAt = Date.now();
  const isStale = staleAt(now);

  const candidates: string[] = [];
  let pageToken: string | undefined;
  do {
    const page = await auth.listUsers(1000, pageToken);
    for (const user of page.users) {
      if (isStale(user)) candidates.push(user.uid);
    }
    pageToken = page.pageToken;
  } while (pageToken);

  for (let i = 0; i < candidates.length; i += CHUNK) {
    if (Date.now() - startedAt > BUDGET_MS) break;
    // 一覧を取ってから、端末がまた使われたり、メールが結びついたりしていることがある
    const { users } = await auth.getUsers(
      candidates.slice(i, i + CHUNK).map((uid) => ({ uid })),
    );

    const revoked: string[] = [];
    for (const user of users.filter(isStale)) {
      try {
        await revokeAll(user.uid, Timestamp.fromMillis(now.toMillis()));
        revoked.push(user.uid);
      } catch (err) {
        console.error(`付与を外せませんでした: ${user.uid}`, err);
      }
    }

    // 付与を先に外す。逆だと、消えたアカウントの付与だけが残る
    const result = await auth.deleteUsers(revoked);
    for (const { index, error } of result.errors) {
      console.error(`アカウントを消せませんでした: ${revoked[index]}`, error);
    }

    // deleteUsers は秒に1回まで
    await sleep(1000);
  }
};

const staleAt = (now: DateTime) => {
  const cutoff = now.minus({ days: UNUSED_DAYS }).toMillis();

  return (user: UserRecord) => {
    if (user.providerData.length > 0 || user.email || user.phoneNumber) {
      return false;
    }
    // 時刻の無いアカウントは、いつ使われたか分からないまま残り続ける
    const usedAt = lastUsedAt(user);
    return Number.isNaN(usedAt) || usedAt < cutoff;
  };
};

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

  await firestore.runTransaction(async (tx) => {
    const displays = [];
    for (const binding of bindings.docs) {
      const resource = binding.get("resource");
      if (
        binding.get("role") === "roles/group.display" &&
        typeof resource === "string" &&
        resource.startsWith("group:")
      ) {
        displays.push(
          firestore
            .collection("groups")
            .doc(resource.slice("group:".length))
            .collection("displays")
            .doc(uid),
        );
      }
    }

    const snapshots = displays.length > 0 ? await tx.getAll(...displays) : [];
    for (const binding of bindings.docs) tx.delete(binding.ref);
    for (const display of snapshots) {
      if (display.exists) tx.update(display.ref, { removed_at: removedAt });
    }
  });
};

export default cleanupAnonymousUsers;
