// binding を1行付与する。ロール名は ROLES で確かめるので、綴りを間違えた付与は書き込めない。
//
//   pnpm run grant -- --subject user:<uid> --role <role> --resource group:<id> [--project <id>] [--yes]
//
// --project を省くとエミュレータに書く。uid とグループ ID をそのまま出すので、公開ログの残る Actions からは流さない。
import { parseBindingArgs } from "./lib/binding_args.js";
import { selectTarget } from "./lib/target.js";

const { uid, role, groupId, ...options } = parseBindingArgs("grant");
const subject = `user:${uid}`;
const resource = `group:${groupId}`;

const target = await selectTarget(options);

// 書き込み先が決まってから Firestore クライアントを初期化する
const { grant } = await import("../src/authz/binding.js");
const { user } = await import("../src/authz/principal.js");
const { group } = await import("../src/authz/resource.js");
const { firestore } = await import("../src/clients/firebase.js");

// 打ち間違えた ID に付与して「付与しました」と出ると、本来のグループに付いていないことに気づけない。
const groupSnapshot = await firestore.collection("groups").doc(groupId).get();
if (!groupSnapshot.exists) {
  await firestore.terminate();
  console.error(`${target} にグループがありません: ${resource}`);
  process.exit(1);
}

const result = await grant({
  principal: user(uid),
  role,
  resource: group(groupId),
});

console.info(
  result === "created"
    ? `${target} に ${subject} / ${role} / ${resource} を付与しました。`
    : `${target} には ${subject} / ${role} / ${resource} がすでにあります。`,
);

await firestore.terminate();
