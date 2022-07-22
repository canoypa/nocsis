import { HttpsError } from "firebase-functions/v1/https";
import { DateTime } from "luxon";
import { fetchCalendar, FetchCalendarParams } from "../../../core/calendar";
import { encodeCalendarEvent } from "../../../core/calendar/encode";
import { parseEvents } from "../../../core/calendar/parseEvents";
import { Events } from "../../../types/events";
import { OnCallHandler } from "../../../types/functions";

type Args = {
  from: string;
  to: string;
  limit: number;
};

const get: OnCallHandler<Events, Args> = async (data, context) => {
  if (!context.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be authenticated to use this function"
    );
  }

  const calendarId = process.env.EVENTS_CALENDAR_ID;
  if (!calendarId) {
    throw new HttpsError("internal", "Internal error");
  }

  const from = DateTime.fromISO(data.from, { zone: "asia/tokyo" });
  const to = data.to
    ? DateTime.fromISO(data.to, { zone: "asia/tokyo" })
    : undefined;
  if (from === null) {
    throw new HttpsError("invalid-argument", "date is not ISO format");
  }

  const options: FetchCalendarParams = {
    timeMin: from,
    timeMax: to,
    singleEvents: true,
    orderBy: "startTime",
    maxResults: data.limit,
  };

  const snapshot = await fetchCalendar(calendarId, options);
  if (!snapshot.items) {
    throw new HttpsError("internal", "Internal error");
  }

  const events = parseEvents(snapshot.items);

  return {
    isEmpty: events.length === 0,
    items: events.map((v) => encodeCalendarEvent(v)),
  };
};
export default get;
