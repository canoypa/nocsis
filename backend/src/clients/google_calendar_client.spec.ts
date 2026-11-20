import { HttpResponse, http } from "msw";
import { beforeEach, describe, expect, it, vi } from "vitest";
import {
  CALENDAR_EVENTS_URL,
  externalApiServer,
  GOOGLE_OAUTH_TOKEN_URL,
  IAM_GENERATE_ACCESS_TOKEN_URL,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";

useExternalApiServer();

// インスタンスのキャッシュをテストごとに捨てる
const importClient = async () => {
  vi.resetModules();
  return await import("./google_calendar_client.js");
};

const listEvents = async () => {
  const { getCalendarClient } = await importClient();
  const calendar = await getCalendarClient();
  await calendar.events.list({ calendarId: "events" });
  return calendar;
};

describe("getCalendarClient", () => {
  let impersonations: { serviceAccount: string; body: unknown }[];
  let calendarAuthorizations: (string | null)[];

  beforeEach(() => {
    vi.stubEnv("GOOGLE_CLOUD_PROJECT", "test-project");
    impersonations = [];
    calendarAuthorizations = [];
    externalApiServer.use(
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
    await listEvents();

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

  it("2回目以降は同じインスタンスを返すこと", async () => {
    const { getCalendarClient } = await importClient();

    const first = await getCalendarClient();
    const second = await getCalendarClient();

    expect(second).toBe(first);
  });

  describe("GOOGLE_CLOUD_PROJECT も GCLOUD_PROJECT も無い場合", () => {
    it("エラーになること", async () => {
      vi.stubEnv("GOOGLE_CLOUD_PROJECT", undefined);
      vi.stubEnv("GCLOUD_PROJECT", undefined);
      const { getCalendarClient } = await importClient();

      await expect(getCalendarClient()).rejects.toThrow(
        "GOOGLE_CLOUD_PROJECT が設定されていません",
      );
    });
  });

  describe("なりすましを断られた場合", () => {
    it("カレンダーを呼ばずにエラーになること", async () => {
      externalApiServer.use(
        http.post(IAM_GENERATE_ACCESS_TOKEN_URL, () =>
          HttpResponse.json(
            {
              error: {
                code: 403,
                message:
                  "Permission 'iam.serviceAccounts.getAccessToken' denied",
                status: "PERMISSION_DENIED",
              },
            },
            { status: 403 },
          ),
        ),
      );

      await expect(listEvents()).rejects.toThrow("getAccessToken");
      expect(calendarAuthorizations).toEqual([]);
    });
  });

  describe("元のトークンの取得に失敗した場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        http.post(GOOGLE_OAUTH_TOKEN_URL, () =>
          HttpResponse.json(
            { error: "invalid_grant", error_description: "Invalid JWT" },
            { status: 400 },
          ),
        ),
      );

      await expect(listEvents()).rejects.toThrow("invalid_grant");
    });
  });
});
