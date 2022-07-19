import {
  auth,
  calendar,
  calendar_v3 as CalendarV3,
} from "@googleapis/calendar";
import { JWT } from "google-auth-library";

let instance: CalendarV3.Calendar;

/**
 * サービスアカウントの認証処理
 */
const authorize = async (): Promise<JWT> => {
  const keyEnv = process.env.CALENDAR_ACCOUNT_KEY;

  if (!keyEnv) {
    throw new Error("Can not read CALENDAR_ACCOUNT_KEY");
  }

  const key = JSON.parse(keyEnv);

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

  const auth = await authorize();
  instance = calendar({ version: "v3", auth });

  return instance;
};
