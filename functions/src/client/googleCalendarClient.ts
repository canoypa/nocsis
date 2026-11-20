import { type calendar_v3 as CalendarV3, calendar } from "@googleapis/calendar";
import { GoogleAuth, Impersonated } from "google-auth-library";

let instance: CalendarV3.Calendar;

/**
 * カレンダーが共有されている events-reader になりすます
 */
const authorize = async () => {
  const projectId =
    process.env.GCLOUD_PROJECT ?? process.env.GOOGLE_CLOUD_PROJECT;
  if (!projectId) throw new Error("GCLOUD_PROJECT is not set");

  const sourceClient = await new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
  }).getClient();

  return new Impersonated({
    sourceClient,
    targetPrincipal: `events-reader@${projectId}.iam.gserviceaccount.com`,
    targetScopes: ["https://www.googleapis.com/auth/calendar.events.readonly"],
  });
};

/**
 * Google Calendar API のインスタンスを生成する
 */
export const getCalendarClient = async (): Promise<CalendarV3.Calendar> => {
  if (instance) {
    return instance;
  }

  const auth = await authorize();
  instance = calendar({ version: "v3", auth });

  return instance;
};
