import {
  auth,
  type calendar_v3 as CalendarV3,
  calendar,
} from "@googleapis/calendar";
import { fetchSecret } from "../services/secret_manager_service.js";

let instance: CalendarV3.Calendar | null = null;

/**
 * サービスアカウントの認証処理
 */
const authorize = async () => {
  const keyJson = await fetchSecret("CALENDAR_ACCOUNT_KEY");

  let key: { client_email?: string; private_key?: string };
  try {
    key = JSON.parse(keyJson);
  } catch (_error) {
    throw new Error("Failed to parse CALENDAR_ACCOUNT_KEY as JSON");
  }

  if (!key.client_email || !key.private_key) {
    throw new Error(
      "Invalid service account key: missing client_email or private_key",
    );
  }

  const jwtClient = new auth.JWT({
    email: key.client_email,
    key: key.private_key,
    scopes: ["https://www.googleapis.com/auth/calendar.events"],
  });

  await jwtClient.authorize();

  return jwtClient;
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
