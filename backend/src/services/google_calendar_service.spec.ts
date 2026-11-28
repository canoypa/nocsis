import { DateTime } from "luxon";
import { HttpResponse, http } from "msw";
import { describe, expect, it } from "vitest";

import {
  CALENDAR_EVENTS_URL,
  externalApiServer,
  TEST_ACCESS_TOKEN,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";
import { fetchGoogleCalendarEvents } from "./google_calendar_service.js";

useExternalApiServer();

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
