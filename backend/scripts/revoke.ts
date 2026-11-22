// binding を1行外す。表示端末の失効もこれで行う。
//
//   pnpm run revoke -- --subject user:<uid> --role <role> --resource group:<id> [--project <id>] [--yes]
//
// --project を省くとエミュレータに書く。uid とグループ ID をそのまま出すので、公開ログの残る Actions からは流さない。
import { parseBindingArgs } from "./lib/binding_args.js";
import { selectTarget } from "./lib/target.js";

const { uid, role, groupId, ...options } = parseBindingArgs("revoke");
const subject = `user:${uid}`;
const resource = `group:${groupId}`;

const target = await selectTarget(options);

// 書き込み先が決まってから Firestore クライアントを初期化する
const { revoke } = await import("../src/authz/binding.js");
const { user } = await import("../src/authz/principal.js");
const { group } = await import("../src/authz/resource.js");
const { firestore } = await import("../src/clients/firebase.js");

const result = await revoke({
  principal: user(uid),
  role,
  resource: group(groupId),
});

if (result === "deleted") {
  console.info(
    `${target} から ${subject} / ${role} / ${resource} を外しました。`,
  );
} else {
  // 打ち間違えた ID でも「ありません」になり、外せたと取り違える
  const groupExists = (await firestore.collection("groups").doc(groupId).get())
    .exists;
  console.info(
    `${target} に ${subject} / ${role} / ${resource} はありません。${groupExists ? "" : "グループもありません。"}`,
  );
}

await firestore.terminate();
