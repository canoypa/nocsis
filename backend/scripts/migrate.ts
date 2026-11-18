// src/migrations の移行を名前で選んで流す。既定は書き込まずに件数だけを数える。
//
//   pnpm exec tsx scripts/migrate.ts --name <name>                                   エミュレータ、ドライラン
//   pnpm exec tsx scripts/migrate.ts --name <name> --apply --project <id> [--yes]
//
// 公開リポジトリの Actions から流すので、出すのは件数だけ。
import { parseArgs } from "node:util";
import { selectTarget } from "./target.js";

const { values } = parseArgs({
  args: process.argv.slice(2).filter((arg, i) => !(i === 0 && arg === "--")),
  options: {
    name: { type: "string" },
    apply: { type: "boolean", default: false },
    project: { type: "string" },
    yes: { type: "boolean", default: false },
  },
});

const { name, apply } = values;
if (!name) {
  console.error("--name は必須です。");
  process.exit(1);
}

const target = await selectTarget(values);

const { MIGRATIONS } = await import("../src/migrations/index.js");
const { firestore } = await import("../src/clients/firebase.js");

// in だとプロトタイプの toString なども通るので、自分の持ち物だけを見る。
if (!Object.hasOwn(MIGRATIONS, name)) {
  console.error(
    `移行がありません: ${name}\n流せるもの: ${Object.keys(MIGRATIONS).join(" / ")}`,
  );
  await firestore.terminate();
  process.exit(1);
}

const counts = await MIGRATIONS[name]({ apply });

console.info(
  [
    `${target} で ${name} を${apply ? "流しました" : "ドライランしました (書き込みなし)"}。`,
    ...Object.entries(counts).map(([key, value]) => `${key}: ${value}`),
  ].join("\n"),
);

// 閉じないと gRPC の接続が残り、プロセスが終わらない。
await firestore.terminate();
