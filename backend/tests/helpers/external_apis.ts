import { generateKeyPairSync } from "node:crypto";
import { writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { HttpResponse, http } from "msw";
import { setupServer } from "msw/node";
import { afterAll, afterEach, beforeAll } from "vitest";

const { privateKey, publicKey } = generateKeyPairSync("rsa", {
  modulusLength: 2048,
  privateKeyEncoding: { type: "pkcs8", format: "pem" },
  publicKeyEncoding: { type: "spki", format: "pem" },
});

export const serviceAccountPublicKey = publicKey;

export const serviceAccountKey = {
  type: "service_account",
  project_id: "demo-nocsis",
  private_key_id: "test-key-id",
  private_key: privateKey,
  client_email: "test@demo-nocsis.iam.gserviceaccount.com",
  client_id: "0",
  token_uri: "https://oauth2.googleapis.com/token",
};

export const GOOGLE_OAUTH_TOKEN_URL = "https://oauth2.googleapis.com/token";
export const TEST_ACCESS_TOKEN = "test-access-token";

export const SECRET_MANAGER_ACCESS_URL =
  "https://secretmanager.googleapis.com/v1/projects/:project/secrets/:secret/versions/:version";

export const CALENDAR_EVENTS_URL =
  "https://www.googleapis.com/calendar/v3/calendars/:calendarId/events";

export const OPEN_WEATHER_MAP_CURRENT_URL =
  "https://api.openweathermap.org/data/2.5/weather";
export const OPEN_WEATHER_MAP_FORECAST_URL =
  "https://api.openweathermap.org/data/2.5/forecast";

export const TEST_OPENWEATHERMAP_TOKEN = "test-openweathermap-token";

export const defaultSecrets: Record<string, string> = {
  CALENDAR_ACCOUNT_KEY: JSON.stringify(serviceAccountKey),
  OPENWEATHERMAP_TOKEN: TEST_OPENWEATHERMAP_TOKEN,
};

/**
 * Secret Manager の accessSecretVersion (REST) に応答するハンドラ
 */
export const secretManagerHandler = (secrets: Record<string, string>) =>
  http.get(SECRET_MANAGER_ACCESS_URL, ({ params }) => {
    const [version, method] = String(params.version).split(":");
    const value = secrets[String(params.secret)];
    if (method !== "access" || value === undefined) {
      return HttpResponse.json(
        { error: { code: 404, message: "not found", status: "NOT_FOUND" } },
        { status: 404 },
      );
    }

    return HttpResponse.json({
      name: `projects/${params.project}/secrets/${params.secret}/versions/${version}`,
      payload: { data: Buffer.from(value).toString("base64") },
    });
  });

const defaultHandlers = [
  http.post(GOOGLE_OAUTH_TOKEN_URL, () =>
    HttpResponse.json({
      access_token: TEST_ACCESS_TOKEN,
      expires_in: 3600,
      token_type: "Bearer",
    }),
  ),
  secretManagerHandler(defaultSecrets),
  http.get(CALENDAR_EVENTS_URL, () => HttpResponse.json({ items: [] })),
  http.get(OPEN_WEATHER_MAP_CURRENT_URL, () =>
    HttpResponse.json({
      weather: [{ id: 800, main: "Clear" }],
      main: { temp: 20 },
    }),
  ),
  http.get(OPEN_WEATHER_MAP_FORECAST_URL, () =>
    HttpResponse.json({
      list: [
        { main: { temp: 21 }, pop: 0, weather: [{ id: 800, main: "Clear" }] },
      ],
    }),
  ),
];

export const externalApiServer = setupServer(...defaultHandlers);

/**
 * 外部 API を msw で差し替える
 *
 * msw 3 は HTTP/2 の素通しで応答が返らず Firestore (gRPC) が止まるので、エミュレータを使うテストでは呼ばない
 */
export const useExternalApiServer = () => {
  beforeAll(() => {
    // 開発者の gcloud ADC を拾わないよう、テスト用の鍵を ADC として読ませる
    const credentialsPath = join(
      tmpdir(),
      `nocsis-test-credentials-${process.pid}.json`,
    );
    writeFileSync(credentialsPath, JSON.stringify(serviceAccountKey));
    process.env.GOOGLE_APPLICATION_CREDENTIALS = credentialsPath;

    externalApiServer.listen({ onUnhandledFrame: "error" });
  });

  afterEach(() => {
    externalApiServer.resetHandlers();
  });

  afterAll(() => {
    externalApiServer.close();
  });
};
