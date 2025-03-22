import type { ScheduledEvent } from "firebase-functions/scheduler";
import { DateTime } from "luxon";
import { crontab } from "../../core/crontab.js";

/** 定期実行 */
const main = async (event: ScheduledEvent) => {
  const timestamp = DateTime.fromISO(event.scheduleTime);

  await Promise.allSettled([
    crontab(
      "0 7 * * *",
      () => import("../../services/notify_datduty/index.js"),
    )(timestamp),
    crontab(
      "0 7 * * *",
      () => import("../../services/notify_events/index.js"),
    )(timestamp),
  ]);
};
export default main;
