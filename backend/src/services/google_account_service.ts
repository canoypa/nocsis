import assert from "node:assert";

import { FieldValue } from "firebase-admin/firestore";
import { OAuth2Client } from "google-auth-library";

import { auth, firestore } from "../clients/firebase.js";
import { AppConfig } from "../config/app_config.js";

const GOOGLE_PROVIDER_ID = "google.com";

const oauth2Client = new OAuth2Client();

export type GoogleAccount = { id: string; email: string | undefined };

/**
 * Google のアクセストークンから、持ち主の Google アカウントを得る。
 * 別のアプリ向けに発行されたトークンは、そのアプリが持ち主になりすませるので受け付けない
 */
export const verifyGoogleAccessToken = async (
  accessToken: string,
): Promise<GoogleAccount | null> => {
  const projectId =
    process.env.GOOGLE_CLOUD_PROJECT ?? process.env.GCLOUD_PROJECT;
  assert(projectId, "GOOGLE_CLOUD_PROJECT が設定されていません");
  const clientId = AppConfig.GOOGLE_OAUTH_CLIENT_IDS[projectId];
  assert(clientId, `${projectId} の OAuth クライアントがありません`);

  let info: Awaited<ReturnType<OAuth2Client["getTokenInfo"]>>;
  try {
    info = await oauth2Client.getTokenInfo(accessToken);
  } catch (err) {
    // 無効なトークンは 400 で返る。Google 側の障害は、トークンのせいにしない
    const status = (err as { response?: { status?: number } }).response?.status;
    if (status !== undefined && status < 500) {
      return null;
    }
    throw err;
  }

  if (info.aud !== clientId || !info.sub) {
    return null;
  }

  return {
    id: info.sub,
    // 型は boolean だが、tokeninfo は "true" / "false" の文字列で返す
    email: String(info.email_verified) === "true" ? info.email : undefined,
  };
};

export type ReplaceGoogleAccountResult =
  | { ok: true }
  | { ok: false; reason: "linked_to_another_user" | "in_progress" };

/** 差し替えの途中で止まったときに、元の Google アカウントを付け直せるよう控えておく */
const SWAP_COLLECTION = "googleAccountSwaps";

const isAuthError = (err: unknown, ...codes: string[]) =>
  err instanceof Error && "code" in err && codes.includes(String(err.code));

const linkGoogleAccount = (uid: string, account: GoogleAccount) =>
  auth.updateUser(uid, {
    providerToLink: {
      providerId: GOOGLE_PROVIDER_ID,
      uid: account.id,
      email: account.email,
    },
  });

const findGoogleAccountOwner = (googleId: string) =>
  auth
    .getUserByProviderUid(GOOGLE_PROVIDER_ID, googleId)
    .catch((err: unknown) => {
      if (isAuthError(err, "auth/user-not-found")) return null;
      throw err;
    });

/**
 * ユーザーに連携する Google アカウントを差し替える。
 * Firebase は外すのと付けるのを1回の更新で受け付けない（付ける方を先に検査して
 * PROVIDER_ALREADY_LINKED になる）ので、外してから付け、付けられなければ元に戻す
 */
export const replaceGoogleAccount = async (
  uid: string,
  account: GoogleAccount,
): Promise<ReplaceGoogleAccountResult> => {
  const owner = await findGoogleAccountOwner(account.id);
  if (owner) {
    return owner.uid === uid
      ? { ok: true }
      : { ok: false, reason: "linked_to_another_user" };
  }

  const user = await auth.getUser(uid);
  const linked = user.providerData.find(
    (provider) => provider.providerId === GOOGLE_PROVIDER_ID,
  );
  const previous: GoogleAccount | undefined = linked && {
    id: linked.uid,
    email: linked.email,
  };

  const swapRef = firestore.collection(SWAP_COLLECTION).doc(uid);
  if (previous) {
    // 同じユーザーの差し替えが重なると、互いの外す・付けるが入り混じる。
    // 元に戻せなかった記録が残っているときも、付け直すまで進めない
    const started = await swapRef
      .create({
        previous: { id: previous.id, email: previous.email ?? null },
        next: { id: account.id, email: account.email ?? null },
        startedAt: FieldValue.serverTimestamp(),
      })
      .then(
        () => true,
        (err: unknown) => {
          if (isFirestoreAlreadyExists(err)) return false;
          throw err;
        },
      );
    if (!started) return { ok: false, reason: "in_progress" };

    try {
      await auth.updateUser(uid, { providersToUnlink: [GOOGLE_PROVIDER_ID] });
    } catch (err) {
      await swapRef.delete();
      throw err;
    }
  }

  try {
    await linkGoogleAccount(uid, account);
  } catch (err) {
    if (previous) {
      await restoreGoogleAccount(uid, previous, err);
      await swapRef.delete();
    }
    // 確かめてから付けるまでの間に、別のユーザーが同じアカウントを連携したとき。
    // Admin SDK はこのエラー (FEDERATED_USER_ID_ALREADY_LINKED) を internal-error にするので、持ち主を見直す
    const owner = await findGoogleAccountOwner(account.id);
    if (owner && owner.uid !== uid) {
      return { ok: false, reason: "linked_to_another_user" };
    }
    throw err;
  }

  if (previous) {
    await swapRef.delete();
  }
  return { ok: true };
};

// gRPC の ALREADY_EXISTS
const isFirestoreAlreadyExists = (err: unknown) =>
  err instanceof Error && "code" in err && err.code === 6;

const RESTORE_ATTEMPTS = 3;

const restoreGoogleAccount = async (
  uid: string,
  previous: GoogleAccount,
  linkError: unknown,
) => {
  let lastError: unknown;
  for (let attempt = 1; attempt <= RESTORE_ATTEMPTS; attempt++) {
    try {
      await linkGoogleAccount(uid, previous);
      return;
    } catch (err) {
      lastError = err;
      if (attempt < RESTORE_ATTEMPTS) {
        await new Promise((resolve) => setTimeout(resolve, 500 * attempt));
      }
    }
  }
  console.log(
    JSON.stringify({
      severity: "ERROR",
      message: `Google アカウントを元に戻せなかった。${SWAP_COLLECTION} の記録から付け直す`,
      uid,
      linkError: String(linkError),
      restoreError: String(lastError),
    }),
  );
  throw new Error("Google アカウントを元に戻せなかった", { cause: lastError });
};
