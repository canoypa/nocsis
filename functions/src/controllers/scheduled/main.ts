import type { ScheduledEvent } from "firebase-functions/scheduler";
import { DateTime } from "luxon";

import { crontab } from "../../core/crontab.js";

/** 定期実行 */
const main = async (event: ScheduledEvent) => {
  const timestamp = DateTime.fromISO(event.scheduleTime);

  const results = await Promise.allSettled([
    crontab(
      "0 7 * * *",
      () => import("../../services/notify_datduty/index.js"),
    )(timestamp),
    crontab(
      "0 7 * * *",
      () => import("../../services/notify_events/index.js"),
    )(timestamp),
    crontab(
      "0 3 * * *",
      () => import("../../services/cleanup_anonymous_users/index.js"),
    )(timestamp),
  ]);

  for (const result of results) {
    if (result.status === "rejected") console.error(result.reason);
  }
};
export default main;
