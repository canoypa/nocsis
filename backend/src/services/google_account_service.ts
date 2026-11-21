import assert from "node:assert";
import { OAuth2Client } from "google-auth-library";
import { auth } from "../clients/firebase.js";
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
  } catch {
    return null;
  }

  if (info.aud !== clientId || !info.sub) {
    return null;
  }

  return { id: info.sub, email: info.email };
};

export type ReplaceGoogleAccountResult =
  | { ok: true }
  | { ok: false; reason: "linked_to_another_user" };

/**
 * ユーザーに連携する Google アカウントを差し替える。
 * 外すのと付けるのを1回の更新で行い、途中で Google の連携が無い状態を作らない
 */
export const replaceGoogleAccount = async (
  uid: string,
  account: GoogleAccount,
): Promise<ReplaceGoogleAccountResult> => {
  const owner = await auth
    .getUserByProviderUid(GOOGLE_PROVIDER_ID, account.id)
    .catch((err: unknown) => {
      if (
        err instanceof Error &&
        "code" in err &&
        err.code === "auth/user-not-found"
      ) {
        return null;
      }
      throw err;
    });
  if (owner) {
    return owner.uid === uid
      ? { ok: true }
      : { ok: false, reason: "linked_to_another_user" };
  }

  const user = await auth.getUser(uid);
  const linked = user.providerData.some(
    (provider) => provider.providerId === GOOGLE_PROVIDER_ID,
  );

  await auth.updateUser(uid, {
    ...(linked ? { providersToUnlink: [GOOGLE_PROVIDER_ID] } : {}),
    providerToLink: {
      providerId: GOOGLE_PROVIDER_ID,
      uid: account.id,
      email: account.email,
    },
  });

  return { ok: true };
};
