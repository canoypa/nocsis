import { parseExpression } from "cron-parser";
import { DateTime } from "luxon";
import { startTransition } from "react";
import { AtomEffect, atomFamily } from "recoil";
import { getNewDate } from "../core/date";
import { clientEffect } from "../core/recoil_client_effect";

/**
 * 渡された cron の実行時刻に状態を更新する effect
 */
const dateEffect = (crontab: string): AtomEffect<DateTime> => {
  return clientEffect(({ setSelf }) => {
    let timeoutId = 0;

    const interval = parseExpression(crontab);

    const update = () => {
      const now = getNewDate();

      startTransition(() => {
        setSelf(now);
      });

      interval.reset(now.toISO());

      const next = DateTime.fromISO(interval.next().toISOString());
      const diff = next.diff(now).as("milliseconds");

      timeoutId = window.setTimeout(update, diff);
    };
    update();

    return () => {
      window.clearTimeout(timeoutId);
    };
  });
};

export const CronDateState = atomFamily({
  key: "CronDateState",
  effects: (crontab: string) => [dateEffect(crontab)],
});

export const DayState = CronDateState("0 0 * * *");
export const HourState = CronDateState("0 * * * *");
export const MinuteState = CronDateState("* * * * *");
