import { SecretManagerServiceClient } from "@google-cloud/secret-manager";

// 既定の gRPC だとテストで msw が HTTP を差し替えられず、ライブラリ更新を踏めないので REST にしている
export const secretManagerClient = new SecretManagerServiceClient({
  fallback: true,
});
