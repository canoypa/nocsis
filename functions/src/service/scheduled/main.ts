import { DateTime } from "luxon";
import { crontab } from "../../core/crontab";
import { PubSubOnRunHandler } from "../../types/functions";

/** 定期実行 */
const main: PubSubOnRunHandler = async (context) => {
  const timestamp = DateTime.fromISO(context.timestamp);

  await Promise.allSettled([
    crontab("0 7 * * *", () => import("./notifyDayduty"))(timestamp),
    crontab("0 7 * * *", () => import("./notifyEvent"))(timestamp),
  ]);
};
export default main;
