import { region } from "firebase-functions";

// 毎分実行
// 実際の実行タイミングは各関数で設定する
export const main = region("asia-northeast1")
  .runWith({
    memory: "512MB",
    maxInstances: 1,
    secrets: ["CALENDAR_ACCOUNT_KEY", "SLACK_TOKEN"],
  })
  .pubsub.schedule("* * * * *")
  .timeZone("Asia/Tokyo")
  .onRun(async (...args) => {
    return (await import("./main.js")).default(...args).catch(console.error);
  });
