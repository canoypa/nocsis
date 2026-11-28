import { generateKeyPairSync, sign } from "node:crypto";
import { HttpResponse, http } from "msw";
import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  externalApiServer,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";
import { verifySchedulerToken } from "./scheduler_token_service.js";

const CERTS_URL = "https://www.googleapis.com/oauth2/v1/certs";
const KEY_ID = "test-scheduler-key";

const { privateKey, publicKey } = generateKeyPairSync("rsa", {
  modulusLength: 2048,
  privateKeyEncoding: { type: "pkcs8", format: "pem" },
  publicKeyEncoding: { type: "spki", format: "pem" },
});

useExternalApiServer();

const base64url = (value: object) =>
  Buffer.from(JSON.stringify(value)).toString("base64url");

/** Google が Cloud Scheduler のために発行するのと同じ形の OIDC トークン */
const idToken = (overrides: Record<string, unknown> = {}, key = privateKey) => {
  const now = Math.floor(Date.now() / 1000);
  const unsigned = `${base64url({ alg: "RS256", kid: KEY_ID, typ: "JWT" })}.${base64url(
    {
      iss: "https://accounts.google.com",
      aud: "nocsis-backend-jobs",
      sub: "1234567890",
      email: "backend-jobs@nocsis-development.iam.gserviceaccount.com",
      email_verified: true,
      iat: now,
      exp: now + 3600,
      ...overrides,
    },
  )}`;
  const signature = sign("RSA-SHA256", Buffer.from(unsigned), key);
  return `${unsigned}.${signature.toString("base64url")}`;
};

describe("verifySchedulerToken", () => {
  beforeEach(() => {
    vi.stubEnv("GOOGLE_CLOUD_PROJECT", "nocsis-development");
    externalApiServer.use(
      http.get(CERTS_URL, () =>
        HttpResponse.json(
          { [KEY_ID]: publicKey },
          { headers: { "Cache-Control": "max-age=0" } },
        ),
      ),
    );
  });

  it("ジョブ用の SA がジョブ向けに発行したトークンを通す", async () => {
    expect(await verifySchedulerToken(idToken())).toBe(true);
  });

  it("別の SA のトークンは通さない", async () => {
    const token = idToken({
      email: "backend-runtime@nocsis-development.iam.gserviceaccount.com",
    });

    expect(await verifySchedulerToken(token)).toBe(false);
  });

  it("別のプロジェクトの同じ名前の SA のトークンは通さない", async () => {
    const token = idToken({
      email: "backend-jobs@another-project.iam.gserviceaccount.com",
    });

    expect(await verifySchedulerToken(token)).toBe(false);
  });

  it("確認されていないメールアドレスのトークンは通さない", async () => {
    expect(await verifySchedulerToken(idToken({ email_verified: false }))).toBe(
      false,
    );
  });

  it("別の相手向けのトークンは通さない", async () => {
    expect(
      await verifySchedulerToken(idToken({ aud: "https://example.com" })),
    ).toBe(false);
  });

  it("期限の切れたトークンは通さない", async () => {
    const past = Math.floor(Date.now() / 1000) - 7200;

    expect(
      await verifySchedulerToken(idToken({ iat: past, exp: past + 3600 })),
    ).toBe(false);
  });

  it("Google の鍵で署名されていないトークンは通さない", async () => {
    const other = generateKeyPairSync("rsa", {
      modulusLength: 2048,
      privateKeyEncoding: { type: "pkcs8", format: "pem" },
      publicKeyEncoding: { type: "spki", format: "pem" },
    });

    expect(await verifySchedulerToken(idToken({}, other.privateKey))).toBe(
      false,
    );
  });
});
