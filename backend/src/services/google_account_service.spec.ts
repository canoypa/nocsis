import { HttpResponse, http } from "msw";
import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  externalApiServer,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";
import { AppConfig } from "../config/app_config.js";
import { verifyGoogleAccessToken } from "./google_account_service.js";

const TOKEN_INFO_URL = "https://oauth2.googleapis.com/tokeninfo";
const CLIENT_ID = AppConfig.GOOGLE_OAUTH_CLIENT_IDS["nocsis-development"];

useExternalApiServer();

const tokenInfo = (overrides: Record<string, unknown> = {}) =>
  http.post(TOKEN_INFO_URL, () =>
    HttpResponse.json({
      aud: CLIENT_ID,
      azp: CLIENT_ID,
      sub: "google_user",
      email: "user@example.com",
      email_verified: "true",
      scope: "openid email",
      expires_in: 3599,
      ...overrides,
    }),
  );

describe("verifyGoogleAccessToken", () => {
  beforeEach(() => {
    vi.stubEnv("GOOGLE_CLOUD_PROJECT", "nocsis-development");
  });

  it("このアプリ向けのトークンなら、持ち主の Google アカウントを返す", async () => {
    externalApiServer.use(tokenInfo());

    expect(await verifyGoogleAccessToken("token")).toEqual({
      id: "google_user",
      email: "user@example.com",
    });
  });

  it("確認されていないメールアドレスは返さない", async () => {
    externalApiServer.use(tokenInfo({ email_verified: "false" }));

    expect(await verifyGoogleAccessToken("token")).toEqual({
      id: "google_user",
      email: undefined,
    });
  });

  it("別のアプリ向けのトークンなら null を返す", async () => {
    externalApiServer.use(
      tokenInfo({ aud: "other.apps.googleusercontent.com" }),
    );

    expect(await verifyGoogleAccessToken("token")).toBeNull();
  });

  it("無効なトークンなら null を返す", async () => {
    externalApiServer.use(
      http.post(TOKEN_INFO_URL, () =>
        HttpResponse.json({ error: "invalid_token" }, { status: 400 }),
      ),
    );

    expect(await verifyGoogleAccessToken("token")).toBeNull();
  });
});
