import { DateTime } from "luxon";
import { HttpResponse, http } from "msw";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import {
  CALENDAR_EVENTS_URL,
  externalApiServer,
  TEST_ACCESS_TOKEN,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";
import {
  clearCalendarCache,
  fetchGoogleCalendarEvents,
} from "./google_calendar_service.js";

useExternalApiServer();

beforeEach(() => {
  clearCalendarCache();
});

describe("fetchGoogleCalendarEvents", () => {
  it("指定したカレンダーのイベントを取得できること", async () => {
    let request: Request | undefined;
    let calendarId: string | undefined;
    externalApiServer.use(
      http.get(CALENDAR_EVENTS_URL, (info) => {
        request = info.request;
        calendarId = String(info.params.calendarId);
        return HttpResponse.json({
          items: [
            {
              summary: "1限目",
              start: { dateTime: "2024-01-01T09:00:00+09:00" },
              end: { dateTime: "2024-01-01T10:30:00+09:00" },
            },
          ],
        });
      }),
    );

    const result = await fetchGoogleCalendarEvents("class@group.calendar", {
      maxResults: 10,
      singleEvents: true,
      timeMin: DateTime.fromISO("2024-01-01T00:00:00+09:00", {
        setZone: true,
      }),
      timeMax: DateTime.fromISO("2024-01-31T23:59:59+09:00", {
        setZone: true,
      }),
      orderBy: "startTime",
      fields: "items(start,end,summary)",
    });

    expect(result).toEqual({
      items: [
        {
          summary: "1限目",
          start: { dateTime: "2024-01-01T09:00:00+09:00" },
          end: { dateTime: "2024-01-01T10:30:00+09:00" },
        },
      ],
    });

    expect(calendarId).toBe("class@group.calendar");
    expect(request?.headers.get("authorization")).toBe(
      `Bearer ${TEST_ACCESS_TOKEN}`,
    );
    const query = Object.fromEntries(new URL(request?.url ?? "").searchParams);
    expect(query).toEqual({
      maxResults: "10",
      singleEvents: "true",
      timeMin: "2024-01-01T00:00:00.000+09:00",
      timeMax: "2024-01-31T23:59:59.000+09:00",
      orderBy: "startTime",
      fields: "items(start,end,summary)",
    });
  });

  describe("カレンダーが見つからない場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        http.get(CALENDAR_EVENTS_URL, () =>
          HttpResponse.json(
            { error: { code: 404, message: "Not Found" } },
            { status: 404 },
          ),
        ),
      );

      await expect(
        fetchGoogleCalendarEvents("missing@group.calendar", {}),
      ).rejects.toThrow("Not Found");
    });
  });
});

describe("fetchGoogleCalendarEvents のキャッシュ", () => {
  const countRequests = () => {
    const count = { events: 0 };
    externalApiServer.events.on("request:start", ({ request }) => {
      if (new URL(request.url).pathname.endsWith("/events")) count.events++;
    });
    return count;
  };

  const day = (iso: string) => DateTime.fromISO(iso, { setZone: true });

  afterEach(() => {
    externalApiServer.events.removeAllListeners();
    vi.useRealTimers();
  });

  it("同じ条件を5分以内にもう一度取得しても API を呼ばないこと", async () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    const count = countRequests();
    const params = {
      timeMin: day("2024-01-01T00:00:00+09:00"),
      timeMax: day("2024-01-02T00:00:00+09:00"),
    };

    const first = await fetchGoogleCalendarEvents(
      "class@group.calendar",
      params,
    );
    vi.advanceTimersByTime(5 * 60 * 1000 - 1);
    const second = await fetchGoogleCalendarEvents("class@group.calendar", {
      timeMin: day("2024-01-01T00:00:00+09:00"),
      timeMax: day("2024-01-02T00:00:00+09:00"),
    });

    expect(second).toEqual(first);
    expect(count).toEqual({ events: 1 });
  });

  it("5分経つと API から取り直すこと", async () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    const count = countRequests();

    await fetchGoogleCalendarEvents("class@group.calendar", {});
    vi.advanceTimersByTime(5 * 60 * 1000);
    await fetchGoogleCalendarEvents("class@group.calendar", {});

    expect(count).toEqual({ events: 2 });
  });

  it("カレンダーか条件が違えば別に取得すること", async () => {
    const count = countRequests();

    await fetchGoogleCalendarEvents("class@group.calendar", {
      timeMin: day("2024-01-01T00:00:00+09:00"),
    });
    await fetchGoogleCalendarEvents("event@group.calendar", {
      timeMin: day("2024-01-01T00:00:00+09:00"),
    });
    await fetchGoogleCalendarEvents("class@group.calendar", {
      timeMin: day("2024-01-02T00:00:00+09:00"),
    });

    expect(count).toEqual({ events: 3 });
  });

  it("失敗した結果は使い回さないこと", async () => {
    const count = countRequests();
    let fail = true;
    externalApiServer.use(
      http.get(CALENDAR_EVENTS_URL, () =>
        fail
          ? HttpResponse.json(
              { error: { code: 404, message: "Not Found" } },
              { status: 404 },
            )
          : HttpResponse.json({ items: [] }),
      ),
    );

    await expect(
      fetchGoogleCalendarEvents("class@group.calendar", { maxResults: 1 }),
    ).rejects.toThrow();
    fail = false;
    const result = await fetchGoogleCalendarEvents("class@group.calendar", {
      maxResults: 1,
    });

    expect(result).toEqual({ items: [] });
    expect(count).toEqual({ events: 2 });
  });
});
