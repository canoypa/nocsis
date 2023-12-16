import { DateTime } from "luxon";
import { crontab } from "../../core/crontab.js";
import { PubSubOnRunHandler } from "../../types/functions.js";

/** 定期実行 */
const main: PubSubOnRunHandler = async (context) => {
  const timestamp = DateTime.fromISO(context.timestamp);

  await Promise.allSettled([
    crontab("0 7 * * *", () => import("./notifyDayduty.js"))(timestamp),
    crontab("0 7 * * *", () => import("./notifyEvent.js"))(timestamp),
  ]);
};
export default main;
