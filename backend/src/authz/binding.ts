import { createHash } from "node:crypto";
import { FieldValue } from "firebase-admin/firestore";
import { firestore } from "../clients/firebase.js";
import { isAlreadyExists } from "../clients/firestore_errors.js";
import { type Principal, subject } from "./principal.js";
import { type ResourceRef, type ResourceType, serialize } from "./resource.js";
import { ROLES, type RoleName } from "./roles.js";

export const COLLECTION = "role_bindings";

/**
 * binding は「誰に・どのロールを・どのリソースに」の3つ組。
 *
 * doc ID を3つ組の決定的ハッシュにして、同じ付与が2行入らないようにする
 * （自動 ID の user_joined_groups は同じ参加が複数行入り得た）。
 * 同じ理由で、付与は何度実行しても増えない。
 */
export const bindingId = (
  subjectKey: string,
  role: RoleName,
  resourceKey: string,
): string =>
  createHash("sha256")
    .update(`${subjectKey}|${role}|${resourceKey}`)
    .digest("hex");

export type GrantResult = "created" | "already_granted";

/** そのリソース型に付与できるロール。scope が合わない組み合わせは型で弾く */
export type RoleForResource<T extends ResourceType> = {
  [K in RoleName]: (typeof ROLES)[K]["scope"] extends T ? K : never;
}[RoleName];

/**
 * 付与を1行作る。すでに同じ3つ組があれば作らず、created_at も書き換えない。
 *
 * 「誰が付けたか」は持たない。binding が表すのは今の状態で、付与という行為は
 * 別の事実（寿命も更新のされ方も違う）。行為の記録は Cloud Audit Logs にある。
 */
export const grant = async <R extends ResourceRef>(
  params: {
    principal: Principal;
    role: RoleForResource<R["type"]>;
    resource: R;
  },
  options: {
    /** 書き込まずに、付与したら何になるかだけを返す。確かめる中身は書き込むときと同じ */
    dryRun?: boolean;
  } = {},
): Promise<GrantResult> => {
  const { principal, role, resource } = params;

  // 型でも弾いているが、CLI のように実行時に組み立てる経路があるので確かめる
  if (ROLES[role].scope !== resource.type) {
    throw new Error(
      `ロール ${role} は ${resource.type} に付与できません（scope: ${ROLES[role].scope}）`,
    );
  }

  const subjectKey = subject(principal);
  const resourceKey = serialize(resource);

  // 区切りを含む ID を通すと、別の3つ組が同じ doc ID になり得る
  if (subjectKey.includes("|") || resourceKey.includes("|")) {
    throw new Error("subject と resource に | は使えません");
  }

  const ref = firestore
    .collection(COLLECTION)
    .doc(bindingId(subjectKey, role, resourceKey));

  if (options.dryRun) {
    return (await ref.get()).exists ? "already_granted" : "created";
  }

  try {
    await ref.create({
      subject: subjectKey,
      role,
      resource: resourceKey,
      created_at: FieldValue.serverTimestamp(),
    });

    return "created";
  } catch (err) {
    if (isAlreadyExists(err)) {
      return "already_granted";
    }

    throw err;
  }
};
