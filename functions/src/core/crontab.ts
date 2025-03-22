import { CronExpressionParser } from "cron-parser";
import { DateTime } from "luxon";

export type CrontabHandler<T = void> = (
  timestamp: DateTime<true>,
) => T | Promise<T>;

/**
 * 入力された時刻が指定した crontab に一致する場合に処理を実行する
 *
 * @param expression crontab 記法
 * @param loadModule 実行する処理を import する関数
 * @returns 時刻を受け取り、crontab に一致する場合 task を実行する関数
 */
export const crontab = (
  expression: string,
  loadModule: () => Promise<{
    default: CrontabHandler;
  }>,
) => {
  return async (date: DateTime): Promise<void> => {
    // 現在時刻を分切り捨てで取得
    const now = date.setZone("asia/tokyo").startOf("minute");

    // crontab の解析
    const interval = CronExpressionParser.parse(expression, {
      tz: "asia/tokyo",
      // nextが現在時刻かをチェックするため、過去の時刻を指定する
      currentDate: now.minus({ minutes: 1 }).toJSDate(),
    });

    const nextStr = interval.next().toISOString();
    if (!nextStr) return;

    const next = DateTime.fromISO(nextStr, { zone: "asia/tokyo" });

    // 現在時刻と一致すれば実行
    const diff = now.diff(next).as("minutes");
    if (diff === 0) {
      return (await loadModule()).default(next);
    }
  };
};
