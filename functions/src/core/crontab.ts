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
  // crontab の解析

  return async (date: DateTime): Promise<void> => {
    // 現在時刻を分切り捨てで取得
    const now = date.setZone("asia/tokyo").startOf("minute");

    const interval = CronExpressionParser.parse(expression, {
      tz: "asia/tokyo",
      currentDate: now.minus({ minutes: 1 }).toJSDate(),
    });

    // 1 分前から見た次のインターバルを取得
    const next = interval.next();
    const dateString = next.toDate();
    const timestamp = DateTime.fromJSDate(dateString, { zone: "asia/tokyo" });

    // 現在時刻と一致すれば実行
    const diff = now.diff(timestamp).as("minutes");
    if (diff === 0) {
      return (await loadModule()).default(timestamp);
    }
  };
};
