import { firestore } from "../clients/firebase.js";
import { type Principal, subject } from "./principal.js";
import { ancestors, type ResourceRef, serialize } from "./resource.js";
import { isRoleName, type Permission, permissionsOf } from "./roles.js";

/**
 * 判定結果。通した場合は「どの binding で通ったか」を持つ。
 *
 * `no_binding` と `insufficient_permission` の区別が 404 と 403 の分かれ目になる
 * （middleware.ts）。
 */
export type Decision =
  | { allowed: true; via: string }
  | { allowed: false; reason: "no_binding" | "insufficient_permission" };

const COLLECTION = "role_bindings";

/**
 * 判定点（PDP）。毎リクエスト Firestore を読む。
 *
 * キャッシュを入れない。プロセス内 TTL キャッシュは失効の遅れを生み、
 * 「権限を外したら即座に何もできない」と衝突する。
 */
export const can = async (
  principal: Principal,
  permission: Permission,
  resource: ResourceRef,
): Promise<Decision> => {
  // Firestore の `in` は 30 要素まで。チェーンは当面1〜2要素
  const chain = ancestors(resource).map(serialize);

  const snapshot = await firestore
    .collection(COLLECTION)
    .where("subject", "==", subject(principal))
    .where("resource", "in", chain)
    .get();

  if (snapshot.empty) {
    return { allowed: false, reason: "no_binding" };
  }

  for (const doc of snapshot.docs) {
    const role = doc.data().role;
    if (isRoleName(role) && permissionsOf(role).includes(permission)) {
      return { allowed: true, via: `${COLLECTION}/${doc.id}` };
    }
  }

  return { allowed: false, reason: "insufficient_permission" };
};
