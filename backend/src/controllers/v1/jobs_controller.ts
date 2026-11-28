import { Hono } from "hono";
import { bearerAuth } from "hono/bearer-auth";
import { DateTime } from "luxon";

import { skipAuthorization } from "../../middlewares/authorize.js";
import { finalizeAllDayduty } from "../../services/dayduty_finalize_service.js";
import { notifyAllDayduty } from "../../services/dayduty_notify_service.js";
import { verifySchedulerToken } from "../../services/scheduler_token_service.js";

export const jobsRoutes = new Hono();

jobsRoutes.post(
  "/dayduty-finalize",
  bearerAuth({ verifyToken: (token) => verifySchedulerToken(token) }),
  skipAuthorization(
    "Cloud Scheduler だけが呼ぶ。呼び手はトークンの SA で確かめる",
  ),
  async (c) => {
    const failed = await finalizeAllDayduty(DateTime.now());
    return c.json({ failed }, failed.length === 0 ? 200 : 500);
  },
);

jobsRoutes.post(
  "/dayduty-notify",
  bearerAuth({ verifyToken: (token) => verifySchedulerToken(token) }),
  skipAuthorization(
    "Cloud Scheduler だけが呼ぶ。呼び手はトークンの SA で確かめる",
  ),
  async (c) => {
    const failed = await notifyAllDayduty(DateTime.now());
    return c.json({ failed }, failed.length === 0 ? 200 : 500);
  },
);
