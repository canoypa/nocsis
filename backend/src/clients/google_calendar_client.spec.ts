import { createVerify } from "node:crypto";
import { HttpResponse, http } from "msw";
import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  defaultSecrets,
  externalApiServer,
  GOOGLE_OAUTH_TOKEN_URL,
  secretManagerHandler,
  serviceAccountKey,
  serviceAccountPublicKey,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";

useExternalApiServer();

const decodeJwtPart = (part: string) =>
  JSON.parse(Buffer.from(part, "base64url").toString());

// インスタンスとシークレットのキャッシュをテストごとに捨てる
const importClient = async () => {
  vi.resetModules();
  return await import("./google_calendar_client.js");
};

describe("getCalendarClient", () => {
  let tokenRequests: URLSearchParams[];

  beforeEach(() => {
    tokenRequests = [];
    externalApiServer.use(
      http.post(GOOGLE_OAUTH_TOKEN_URL, async ({ request }) => {
        tokenRequests.push(new URLSearchParams(await request.text()));
        return HttpResponse.json({
          access_token: "test-access-token",
          expires_in: 3600,
          token_type: "Bearer",
        });
      }),
    );
  });

  it("サービスアカウントの鍵で署名した JWT でアクセストークンを取得すること", async () => {
    const { getCalendarClient } = await importClient();

    await getCalendarClient();

    expect(tokenRequests).toHaveLength(1);
    const body = tokenRequests[0];
    expect(body.get("grant_type")).toBe(
      "urn:ietf:params:oauth:grant-type:jwt-bearer",
    );

    const assertion = body.get("assertion") ?? "";
    const [header, payload, signature] = assertion.split(".");
    expect(decodeJwtPart(header)).toMatchObject({ alg: "RS256" });
    expect(decodeJwtPart(payload)).toMatchObject({
      iss: serviceAccountKey.client_email,
      scope: "https://www.googleapis.com/auth/calendar.events",
      aud: GOOGLE_OAUTH_TOKEN_URL,
    });
    expect(
      createVerify("RSA-SHA256")
        .update(`${header}.${payload}`)
        .verify(serviceAccountPublicKey, signature, "base64url"),
    ).toBe(true);
  });

  it("2回目以降は同じインスタンスを返し、再認証しないこと", async () => {
    const { getCalendarClient } = await importClient();

    const first = await getCalendarClient();
    const second = await getCalendarClient();

    expect(second).toBe(first);
    expect(tokenRequests).toHaveLength(1);
  });

  describe("鍵が JSON でない場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        secretManagerHandler({ CALENDAR_ACCOUNT_KEY: "not-json" }),
      );
      const { getCalendarClient } = await importClient();

      await expect(getCalendarClient()).rejects.toThrow(
        "Failed to parse CALENDAR_ACCOUNT_KEY as JSON",
      );
    });
  });

  describe("鍵に client_email か private_key が無い場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        secretManagerHandler({
          CALENDAR_ACCOUNT_KEY: JSON.stringify({
            client_email: serviceAccountKey.client_email,
          }),
        }),
      );
      const { getCalendarClient } = await importClient();

      await expect(getCalendarClient()).rejects.toThrow(
        "Invalid service account key: missing client_email or private_key",
      );
    });
  });

  describe("トークンの取得に失敗した場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        secretManagerHandler(defaultSecrets),
        http.post(GOOGLE_OAUTH_TOKEN_URL, () =>
          HttpResponse.json(
            { error: "invalid_grant", error_description: "Invalid JWT" },
            { status: 400 },
          ),
        ),
      );
      const { getCalendarClient } = await importClient();

      await expect(getCalendarClient()).rejects.toThrow();
    });
  });
});
