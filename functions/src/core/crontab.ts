import { parseExpression } from "cron-parser";
import { DateTime } from "luxon";

export type CrontabHandler = (timestamp: DateTime) => any | Promise<any>;

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
  }>
): ((date: DateTime) => void) => {
  // crontab の解析
  const interval = parseExpression(expression, { tz: "asia/tokyo" });

  return async (date: DateTime): Promise<void> => {
    // 現在時刻を分切り捨てで取得
    const now = date.setZone("asia/tokyo").startOf("minute");

    // 基準時間を 1 分前に更新
    interval.reset(now.minus({ minutes: 1 }).toISO());

    // 1 分前から見た次のインターバルを取得
    const dateString = interval.next().toISOString();
    const timestamp = DateTime.fromISO(dateString, { zone: "asia/tokyo" });

    // 現在時刻と一致すれば実行
    const diff = now.diff(timestamp).as("minutes");
    if (diff === 0) {
      return (await loadModule()).default(timestamp);
    }
  };
};
