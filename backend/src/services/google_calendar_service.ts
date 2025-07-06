import type { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import type { DateTime } from "luxon";
import { getCalendarClient } from "../clients/google_calendar_client.js";

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

/**
 * カレンダーからイベントを取得する
 */
export const fetchGoogleCalendarEvents = async (
  calendarId: string,
  params: FetchCalendarParams,
): Promise<CalendarV3.Schema$Events> => {
  const calendar = await getCalendarClient();

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

  const res = await calendar.events.list(options);
  return res.data;
};
