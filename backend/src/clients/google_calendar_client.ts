import assert from "node:assert";
import { type calendar_v3 as CalendarV3, calendar } from "@googleapis/calendar";
import { GoogleAuth, Impersonated } from "google-auth-library";

const CALENDAR_SCOPE =
  "https://www.googleapis.com/auth/calendar.events.readonly";

let instance: CalendarV3.Calendar | null = null;

/**
 * カレンダーが共有されている events-reader になりすます
 */
const authorize = async () => {
  const projectId =
    process.env.GOOGLE_CLOUD_PROJECT ?? process.env.GCLOUD_PROJECT;
  assert(projectId, "GOOGLE_CLOUD_PROJECT が設定されていません");

  const sourceClient = await new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/cloud-platform"],
  }).getClient();

  return new Impersonated({
    sourceClient,
    targetPrincipal: `events-reader@${projectId}.iam.gserviceaccount.com`,
    targetScopes: [CALENDAR_SCOPE],
  });
};

/**
 * Google Calendar API のインスタンスを生成する
 */
export const getCalendarClient = async (): Promise<CalendarV3.Calendar> => {
  if (instance) {
    return instance;
  }

  const authClient = await authorize();
  instance = calendar({ version: "v3", auth: authClient });

  return instance;
};
