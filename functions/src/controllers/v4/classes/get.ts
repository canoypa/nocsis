import { getFirestore } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";
import { DateTime } from "luxon";
import { firebaseApp } from "~/client/firebaseApp.js";
import {
  type FetchCalendarParams,
  fetchCalendar,
} from "../../../core/calendar.js";
import { encodeCalendarClass } from "../../../core/calendar/encode.js";
import { parseClasses } from "../../../core/calendar/parseClasses.js";
import type { Classes } from "../../../types/classes.js";

type Args = {
  groupId: string;
  from: string;
  to: string;
};

const get = async (data: Args): Promise<Classes> => {
  const firestore = getFirestore(firebaseApp);

  const groupSnapshot = await firestore
    .collection("groups")
    .doc(data.groupId)
    .get();
  const group = groupSnapshot.data();
  if (!group) {
    throw new HttpsError("invalid-argument", "Group not found");
  }

  const calendarId = group.classes_calendar_id;
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
