import { getFirestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";
import { DateTime } from "luxon";
import { firebaseApp } from "~/client/firebaseApp.js";
import {
  type FetchCalendarParams,
  fetchCalendar,
} from "../../../core/calendar.js";
import { encodeCalendarEvent } from "../../../core/calendar/encode.js";
import { parseEvents } from "../../../core/calendar/parseEvents.js";
import type { Events } from "../../../types/events.js";

type Args = {
  groupId: string;
  from: string;
  to: string;
  limit: number;
};

const get = async (data: Args): Promise<Events> => {
  const firestore = getFirestore(firebaseApp);

  const groupSnapshot = await firestore
    .collection("groups")
    .doc(data.groupId)
    .get();
  const group = groupSnapshot.data();
  if (!group) {
    throw new HttpsError("invalid-argument", "Group not found");
  }

  const calendarId = group.events_calendar_id;
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
    fields: "items(start,end,summary,description,location)",
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
