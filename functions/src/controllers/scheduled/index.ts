import { onSchedule } from "firebase-functions/scheduler";

// 毎分実行
// 実際の実行タイミングは各関数で設定する
export const main = onSchedule(
  {
    region: "asia-northeast1",
    maxInstances: 1,
    secrets: ["CALENDAR_ACCOUNT_KEY"],
    schedule: "* * * * *",
    timeZone: "Asia/Tokyo",
  },
  async (event) => {
    return (await import("./main.js")).default(event).catch(console.error);
  },
);
