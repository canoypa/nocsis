import assert from "node:assert";
import { OAuth2Client, type TokenPayload } from "google-auth-library";
import { AppConfig } from "../config/app_config.js";

const oauth2Client = new OAuth2Client();

/**
 * Cloud Scheduler が付ける OIDC トークンを確かめる。
 * ジョブ用の SA が、この backend のジョブ向けに発行したものだけを通す
 */
export const verifySchedulerToken = async (token: string): Promise<boolean> => {
  const projectId =
    process.env.GOOGLE_CLOUD_PROJECT ?? process.env.GCLOUD_PROJECT;
  assert(projectId, "GOOGLE_CLOUD_PROJECT が設定されていません");

  let payload: TokenPayload | undefined;
  try {
    const ticket = await oauth2Client.verifyIdToken({
      idToken: token,
      audience: AppConfig.JOB_TOKEN_AUDIENCE,
    });
    payload = ticket.getPayload();
  } catch (err) {
    console.warn("ジョブのトークンを確かめられませんでした", err);
    return false;
  }

  return (
    payload?.email_verified === true &&
    payload.email ===
      `${AppConfig.JOB_SERVICE_ACCOUNT}@${projectId}.iam.gserviceaccount.com`
  );
};
