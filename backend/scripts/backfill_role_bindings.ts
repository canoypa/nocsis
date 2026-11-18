// user_joined_groups の参加を role_bindings に写す。何度流しても増えない。
// 参加を消しても binding は残るので、外すときは binding も消す。
//
// 流すのは数回だけなので npm script にしない。backend で:
//   pnpm exec tsx scripts/backfill_role_bindings.ts                          エミュレータ
//   pnpm exec tsx scripts/backfill_role_bindings.ts --project <id> [--yes]
//
// 公開リポジトリの Actions から流すこともあるので、uid やグループ ID は出さず件数だけを出す。
import { parseArgs } from "node:util";
import { selectTarget } from "./target.js";

const { values } = parseArgs({
  args: process.argv.slice(2).filter((arg, i) => !(i === 0 && arg === "--")),
  options: {
    project: { type: "string" },
    yes: { type: "boolean", default: false },
  },
});

const target = await selectTarget(values);

// 書き込み先が決まってから Firestore クライアントを初期化する
const { backfillFromJoinedGroups, JOINED_MEMBER_ROLE } = await import(
  "../src/authz/backfill.js"
);
const { firestore } = await import("../src/clients/firebase.js");

const result = await backfillFromJoinedGroups();

console.info(
  [
    `${target} の user_joined_groups を ${JOINED_MEMBER_ROLE} に写しました。`,
    `rows: ${result.rows}`,
    `created: ${result.created}`,
    `already granted: ${result.alreadyGranted}`,
    `skipped: ${result.skipped}`,
  ].join("\n"),
);

// 閉じないと gRPC の接続が残り、プロセスが終わらない。
await firestore.terminate();
