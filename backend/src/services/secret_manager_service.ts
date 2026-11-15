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
  const secretPath = secretManagerClient.secretVersionPath(
    "class-clock-40088",
    secretName,
    "latest",
  );

  // キャッシュ済みならキャッシュから取得する
  const cachedValue = secretCache.get(secretPath);
  if (cachedValue) return cachedValue;

  const [version] = await secretManagerClient.accessSecretVersion({
    name: secretPath,
  });

  const secret = version.payload?.data?.toString();
  assert(secret, "シークレット値を取得できませんでした");

  // キャッシュする
  secretCache.set(secretPath, secret);

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
