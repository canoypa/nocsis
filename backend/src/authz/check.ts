import { firestore } from "../clients/firebase.js";
import { COLLECTION } from "./binding.js";
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

  // ROLES に無いロール名は何も付与しないので、行があっても binding として数えない。
  // 数えてしまうと、ロールを1つ廃止しただけで、その binding を持つ相手に
  // リソースの存在が見える（404 が 403 に変わる）
  const bindings = snapshot.docs.flatMap((doc) => {
    const role = doc.data().role;

    return isRoleName(role) ? [{ id: doc.id, role }] : [];
  });

  if (bindings.length === 0) {
    return { allowed: false, reason: "no_binding" };
  }

  for (const { id, role } of bindings) {
    if (permissionsOf(role).includes(permission)) {
      return { allowed: true, via: `${COLLECTION}/${id}` };
    }
  }

  return { allowed: false, reason: "insufficient_permission" };
};
