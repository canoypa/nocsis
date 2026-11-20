import { generateKeyPairSync } from "node:crypto";
import { rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { HttpResponse, http } from "msw";
import { setupServer } from "msw/node";
import {
  afterAll,
  afterEach,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from "vitest";

const GOOGLE_OAUTH_TOKEN_URL = "https://oauth2.googleapis.com/token";
const IAM_GENERATE_ACCESS_TOKEN_URL =
  "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/:serviceAccount";
const CALENDAR_EVENTS_URL =
  "https://www.googleapis.com/calendar/v3/calendars/:calendarId/events";

const server = setupServer(
  http.post(GOOGLE_OAUTH_TOKEN_URL, () =>
    HttpResponse.json({
      access_token: "source-token",
      expires_in: 3600,
      token_type: "Bearer",
    }),
  ),
);

const credentialsPath = join(
  tmpdir(),
  `nocsis-functions-test-credentials-${process.pid}.json`,
);

beforeAll(() => {
  // 開発者の gcloud ADC を拾わないよう、テスト用の鍵を ADC として読ませる
  const { privateKey } = generateKeyPairSync("rsa", {
    modulusLength: 2048,
    privateKeyEncoding: { type: "pkcs8", format: "pem" },
    publicKeyEncoding: { type: "spki", format: "pem" },
  });
  writeFileSync(
    credentialsPath,
    JSON.stringify({
      type: "service_account",
      project_id: "test-project",
      private_key_id: "test-key-id",
      private_key: privateKey,
      client_email: "functions-runtime@test-project.iam.gserviceaccount.com",
      client_id: "0",
      token_uri: GOOGLE_OAUTH_TOKEN_URL,
    }),
  );
  vi.stubEnv("GOOGLE_APPLICATION_CREDENTIALS", credentialsPath);
  vi.stubEnv("GCLOUD_PROJECT", "test-project");
  server.listen({ onUnhandledFrame: "error" });
});

afterEach(() => {
  server.resetHandlers();
});

afterAll(() => {
  server.close();
  vi.unstubAllEnvs();
  rmSync(credentialsPath, { force: true });
});

describe("getCalendarClient", () => {
  let impersonations: { serviceAccount: string; body: unknown }[];
  let calendarAuthorizations: (string | null)[];

  beforeEach(() => {
    impersonations = [];
    calendarAuthorizations = [];
    server.use(
      http.post(IAM_GENERATE_ACCESS_TOKEN_URL, async ({ params, request }) => {
        impersonations.push({
          serviceAccount: String(params.serviceAccount),
          body: await request.json(),
        });
        return HttpResponse.json({
          accessToken: "impersonated-token",
          expireTime: new Date(Date.now() + 3600_000).toISOString(),
        });
      }),
      http.get(CALENDAR_EVENTS_URL, ({ request }) => {
        calendarAuthorizations.push(request.headers.get("authorization"));
        return HttpResponse.json({ items: [] });
      }),
    );
  });

  it("動いているプロジェクトの events-reader になりすまし、カレンダーを読む権限だけのトークンで呼ぶこと", async () => {
    vi.resetModules();
    const { getCalendarClient } = await import("./googleCalendarClient.js");

    const calendar = await getCalendarClient();
    await calendar.events.list({ calendarId: "events" });

    expect(impersonations).toEqual([
      {
        serviceAccount:
          "events-reader@test-project.iam.gserviceaccount.com:generateAccessToken",
        body: expect.objectContaining({
          scope: ["https://www.googleapis.com/auth/calendar.events.readonly"],
        }),
      },
    ]);
    expect(calendarAuthorizations).toEqual(["Bearer impersonated-token"]);
  });
});
