import { HttpsError } from "firebase-functions/v1/https";
import { DateTime } from "luxon";
import { fetchCalendar, FetchCalendarParams } from "../../../core/calendar";
import { encodeCalendarClass } from "../../../core/calendar/encode";
import { parseClasses } from "../../../core/calendar/parseClasses";
import { Classes } from "../../../types/classes";
import { OnCallHandler } from "../../../types/functions";

type Args = {
  from: string;
  to: string;
};

const get: OnCallHandler<Classes, Args> = async (data, context) => {
  if (!context.auth) {
    throw new HttpsError(
      "unauthenticated",
      "You must be authenticated to use this function"
    );
  }

  const calendarId = process.env.CLASSES_CALENDAR_ID;
  if (!calendarId) {
    throw new HttpsError("internal", "Internal error");
  }

  const from = DateTime.fromISO(data.from, { zone: "asia/tokyo" });
  const to = DateTime.fromISO(data.to, { zone: "asia/tokyo" });
  if (from === null || to === null) {
    throw new HttpsError("invalid-argument", "date is not ISO format");
  }

  const options: FetchCalendarParams = {
    timeMin: from,
    timeMax: to,
    singleEvents: true,
    orderBy: "startTime",
    fields: "items(start,end,summary)",
  };

  const snapshot = await fetchCalendar(calendarId, options);
  if (!snapshot.items) {
    throw new HttpsError("internal", "Internal error");
  }

  const classes = parseClasses(snapshot.items);

  return {
    isEmpty: classes.length === 0,
    items: classes.map((v) => encodeCalendarClass(v)),
  };
};
export default get;
