import assert from "node:assert";
import { secretManagerClient } from "../clients/secret_manager.js";

const secretCache = new Map<string, string>();

/**
 * Secret Manager からシークレットを取得する
 *
 * @param secretName シークレット名
 * @returns シークレット値
 */
export const fetchSecret = async (secretName: string): Promise<string> => {
  // キャッシュ済みならキャッシュから取得する
  const cachedValue = secretCache.get(secretName);
  if (cachedValue) return cachedValue;

  // 動いているプロジェクトの Secret を読む。Staging から本番の Secret を読ませない。
  // 認証ライブラリの推測 (gcloud の設定やメタデータサーバー) には頼らない。別のプロジェクトを読みうる。
  const projectId =
    process.env.GOOGLE_CLOUD_PROJECT ?? process.env.GCLOUD_PROJECT;
  assert(projectId, "GOOGLE_CLOUD_PROJECT が設定されていません");
  const secretPath = secretManagerClient.secretVersionPath(
    projectId,
    secretName,
    "latest",
  );

  const [version] = await secretManagerClient.accessSecretVersion({
    name: secretPath,
  });

  const secret = version.payload?.data?.toString();
  assert(secret, "シークレット値を取得できませんでした");

  // キャッシュする
  secretCache.set(secretName, secret);

  return secret;
};

/**
 * キャッシュをクリアする
 * テストでしか使ってない
 *
 * @returns void
 */
export const clearSecretCache = (): void => {
  secretCache.clear();
};
