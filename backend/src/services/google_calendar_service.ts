import type { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import type { DateTime } from "luxon";

import { getCalendarClient } from "../clients/google_calendar_client.js";
import { createPromiseCache } from "./promise_cache.js";

export type FetchCalendarParams = Partial<{
  maxResults: number;
  showDeleted: boolean;
  singleEvents: boolean;
  timeMin: DateTime;
  timeMax: DateTime;
  updatedMin: DateTime;
  pageToken: string;
  orderBy: "startTime" | "updated";
  fields: string;
  q: string;
}>;

const CACHE_TTL_MS = 5 * 60 * 1000;
const CACHE_MAX_ENTRIES = 500;

const cache = createPromiseCache<CalendarV3.Schema$Events>({
  ttlMs: CACHE_TTL_MS,
  // Calendar API の上限に届く量ではないので、失敗は同時に来た要求とだけ分け合う
  failureTtlMs: 0,
  maxEntries: CACHE_MAX_ENTRIES,
});

/**
 * カレンダーからイベントを取得する
 *
 * 同じカレンダー・同じ条件の結果は5分間使い回す。
 */
export const fetchGoogleCalendarEvents = (
  calendarId: string,
  params: FetchCalendarParams,
): Promise<CalendarV3.Schema$Events> => {
  const options: CalendarV3.Params$Resource$Events$List = {
    calendarId,
    maxResults: params.maxResults,
    showDeleted: params.showDeleted,
    singleEvents: params.singleEvents,
    timeMin: params.timeMin?.toISO() ?? undefined,
    timeMax: params.timeMax?.toISO() ?? undefined,
    updatedMin: params.updatedMin?.toISO() ?? undefined,
    pageToken: params.pageToken,
    orderBy: params.orderBy,
    fields: params.fields,
    q: params.q,
  };

  return cache.get(toCacheKey(options), () =>
    fetchGoogleCalendarEventsFromApi(options),
  );
};

/**
 * Calendar API に送る要求の URL と同じく、カレンダー ID と条件のクエリでキーを作る
 */
const toCacheKey = ({
  calendarId,
  ...query
}: CalendarV3.Params$Resource$Events$List): string => {
  const params = new URLSearchParams();
  for (const [name, value] of Object.entries(query)) {
    if (
      typeof value === "string" ||
      typeof value === "number" ||
      typeof value === "boolean"
    ) {
      params.set(name, String(value));
    }
  }
  params.sort();
  return `${encodeURIComponent(calendarId ?? "")}?${params}`;
};

/**
 * テスト用: カレンダーのキャッシュを空にする
 */
export const clearCalendarCache = (): void => {
  cache.clear();
};

const fetchGoogleCalendarEventsFromApi = async (
  options: CalendarV3.Params$Resource$Events$List,
): Promise<CalendarV3.Schema$Events> => {
  const calendar = await getCalendarClient();

  const startedAt = performance.now();
  let itemCount: number | null = null;
  try {
    const res = await calendar.events.list(options);
    itemCount = res.data.items?.length ?? 0;
    return res.data;
  } finally {
    console.log(
      JSON.stringify({
        severity: "INFO",
        message: "Google Calendar から予定を取得した",
        succeeded: itemCount !== null,
        durationMs: Math.round(performance.now() - startedAt),
        itemCount,
      }),
    );
  }
};
