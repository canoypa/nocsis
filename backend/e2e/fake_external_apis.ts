// 使い方: tsx --import ./e2e/fake_external_apis.ts src/main.ts
import { generateKeyPairSync } from "node:crypto";
import { registerHooks } from "node:module";

import { DateTime } from "luxon";
import { getResponse, HttpResponse, http } from "msw";

import { secretManagerClient } from "../src/clients/secret_manager.js";

// 鍵をリポジトリに置かない。JWT の署名に本物の RSA 鍵が要るので起動のたびに作る。
const { privateKey } = generateKeyPairSync("rsa", {
  modulusLength: 2048,
  privateKeyEncoding: { type: "pkcs8", format: "pem" },
  publicKeyEncoding: { type: "spki", format: "pem" },
});
const secrets: Record<string, string> = {
  CALENDAR_ACCOUNT_KEY: JSON.stringify({
    client_email: "e2e@example.iam.gserviceaccount.com",
    private_key: privateKey,
  }),
};

// Secret Manager は msw で差し替えない。クライアントが gRPC で fetch を通らない。
// main.ts と同じモジュールのインスタンスなので、ここで差し替えれば backend に効く。
secretManagerClient.accessSecretVersion = (async ({
  name,
}: {
  name: string;
}) => {
  const secretName = name.split("/").at(-3) ?? "";
  const data = secrets[secretName];
  if (data === undefined)
    throw new Error(`E2E に偽のシークレットがありません: ${name}`);
  return [{ payload: { data } }];
}) as unknown as typeof secretManagerClient.accessSecretVersion;

/** scripts/seed.ts のグループが指すカレンダー ID ごとの予定名 */
const calendarTitles: Record<string, string[]> = {
  classes: ["E2E 国語", "E2E 数学"],
  events: ["E2E 遠足"],
};

// 期間内の毎日に予定を置く。日付を固定しないのは、画面が「今日」を基準に表示するため。
const calendarEvents = (calendarId: string, url: URL) => {
  const zone = "Asia/Tokyo";
  const now = DateTime.now().setZone(zone);
  const from = DateTime.fromISO(url.searchParams.get("timeMin") ?? "", {
    zone,
  });
  const to = DateTime.fromISO(url.searchParams.get("timeMax") ?? "", { zone });
  const first = (from.isValid ? from : now).startOf("day");
  const last = to.isValid ? to : first.plus({ days: 7 });

  const items = [];
  for (let day = first; day < last && items.length < 100;) {
    for (const [i, summary] of (calendarTitles[calendarId] ?? []).entries()) {
      const start = day.set({ hour: 9 + i });
      items.push({
        id: `${calendarId}-${start.toFormat("yyyyMMddHH")}`,
        summary,
        start: { dateTime: start.toISO() },
        end: { dateTime: start.plus({ minutes: 50 }).toISO() },
      });
    }
    day = day.plus({ days: 1 });
  }
  return { items };
};

const handlers = [
  http.post("https://oauth2.googleapis.com/token", () =>
    HttpResponse.json({
      access_token: "e2e",
      token_type: "Bearer",
      expires_in: 3600,
    }),
  ),
  http.get(
    "https://www.googleapis.com/calendar/v3/calendars/:calendarId/events",
    ({ params, request }) =>
      HttpResponse.json(
        calendarEvents(String(params.calendarId), new URL(request.url)),
      ),
  ),
  http.get("https://api.open-meteo.com/v1/forecast", () =>
    HttpResponse.json({
      current: { temperature_2m: 20, weather_code: 0 },
      hourly: {
        temperature_2m: Array.from({ length: 25 }, () => 20),
        precipitation_probability: Array.from({ length: 25 }, () => 0),
        weather_code: Array.from({ length: 25 }, () => 0),
      },
    }),
  ),
];

// msw/node の setupServer も msw の FetchInterceptor も使わない。どちらを入れても、
// firebase-admin が gRPC で話す Firestore エミュレータへの接続が返らなくなる。
// fetch だけを差し替えて handlers に流す。
const originalFetch = globalThis.fetch;
const fakedHosts = new Set([
  "oauth2.googleapis.com",
  "www.googleapis.com",
  "api.open-meteo.com",
]);
globalThis.fetch = async (input, init) => {
  const url = new URL(input instanceof Request ? input.url : input);
  // 偽物の無い宛先は Request に包まずに渡す。node-fetch 流の init (ストリームの body
  // など) はネイティブの Request が受け付けない。
  if (!fakedHosts.has(url.hostname)) return originalFetch(input, init);

  const request = new Request(input, init);
  const response = await getResponse(handlers, request.clone());
  return response ?? originalFetch(request);
};

// googleapis の HTTP クライアント (gaxios) は fetch ではなく node-fetch を読み込むので、
// node-fetch を上の fetch に向ける。
const nodeFetchShim = `data:text/javascript,export default (...args) => globalThis.fetch(...args);`;
registerHooks({
  resolve: (specifier, context, nextResolve) =>
    specifier === "node-fetch"
      ? { url: nodeFetchShim, shortCircuit: true }
      : nextResolve(specifier, context),
});
