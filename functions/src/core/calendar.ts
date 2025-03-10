import type { calendar_v3 as CalendarV3 } from "@googleapis/calendar";
import type { DateTime } from "luxon";
import { getCalendarClient } from "../client/googleCalendarClient.js";

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
export const fetchCalendar = async (
  calendarId: string,
  param: FetchCalendarParams,
): Promise<CalendarV3.Schema$Events> => {
  const calendar = await getCalendarClient();

  const options: CalendarV3.Params$Resource$Events$List = {
    calendarId: calendarId,

    maxResults: param.maxResults,
    showDeleted: param.showDeleted,
    singleEvents: param.singleEvents,
    timeMin: param.timeMin?.toISO(),
    timeMax: param.timeMax?.toISO(),
    updatedMin: param.updatedMin?.toISO(),
    pageToken: param.pageToken,
    orderBy: param.orderBy,
    fields: param.fields,
    q: param.q,
  };

  const res = await calendar.events.list(options);

  return res.data;
};
