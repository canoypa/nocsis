// scripts/migrations の移行を名前で選んで流す。既定は書き込まずに件数だけを数える。
//
// 移行は1本1ファイルで scripts/migrations に置き、Migration を default export する。
// ファイル名は「作った日付_何をするか」(例: 20261118_backfill_role_bindings) にして、並びで順序と時期がわかるようにする。
// 一度流せば役目を終えるので、アプリのコード (src) には置かない。
//
//   pnpm exec tsx scripts/migrate.ts --name <name>                                   エミュレータ、ドライラン
//   pnpm exec tsx scripts/migrate.ts --name <name> --apply --project <id> [--yes]
//
// 公開リポジトリの Actions から流すので、出すのは件数だけ。
import { existsSync } from "node:fs";
import { parseArgs } from "node:util";
import type { Migration } from "./migration.js";
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

// 名前をパスとして組み立てるので、区切りや「..」を含められないよう文字を絞る。
// そのうえで scripts/migrations に実在するファイルだけを読む。
const file = new URL(`./migrations/${name}.ts`, import.meta.url);
if (!/^[a-z0-9_]+$/.test(name) || !existsSync(file)) {
  console.error(`移行がありません: ${name}`);
  process.exit(1);
}

// 確認のプロンプトより先に名前を確かめ、打ち間違いで本番の ID を打たせない。
const target = await selectTarget(values);

const { default: migration }: { default?: Migration } = await import(file.href);
if (typeof migration !== "function") {
  console.error(`${name} は Migration を default export していません`);
  process.exit(1);
}
const { firestore } = await import("../src/clients/firebase.js");

const counts = await migration({ apply });

console.info(
  [
    `${target} で ${name} を${apply ? "流しました" : "ドライランしました (書き込みなし)"}。`,
    ...Object.entries(counts).map(([key, value]) => `${key}: ${value}`),
  ].join("\n"),
);

// 閉じないと gRPC の接続が残り、プロセスが終わらない。
await firestore.terminate();
