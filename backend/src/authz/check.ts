import { firestore } from "../clients/firebase.js";
import { COLLECTION } from "./binding.js";
import { type Principal, subject } from "./principal.js";
import { ancestors, type ResourceRef, serialize } from "./resource.js";
import {
  isRoleName,
  PERMISSIONS,
  type Permission,
  permissionsOf,
  ROLES,
} from "./roles.js";

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

  const granting = bindings.find(({ role }) =>
    permissionsOf(role).includes(permission),
  );

  return granting
    ? { allowed: true, via: `${COLLECTION}/${granting.id}` }
    : { allowed: false, reason: "insufficient_permission" };
};

/**
 * ある型のリソースごとに、持っている permission をまとめる。「自分のグループ一覧」のように、
 * 判定する相手が先に決まっていないときに使う。複数のロールがあれば和集合にする。
 *
 * 祖先への付与はまだ無い（ancestors が自分だけを返す）ので、直接の binding だけを見る。
 * 祖先に付与できるようになったら、ここも祖先から辿る。
 */
export const permissionsByResource = async (
  principal: Principal,
  type: ResourceRef["type"],
): Promise<Map<string, Permission[]>> => {
  const snapshot = await firestore
    .collection(COLLECTION)
    .where("subject", "==", subject(principal))
    .select("role", "resource")
    .get();

  const prefix = `${type}:`;
  const granted = new Map<string, Set<Permission>>();

  for (const doc of snapshot.docs) {
    const { role, resource } = doc.data();

    if (
      !isRoleName(role) ||
      ROLES[role].scope !== type ||
      typeof resource !== "string" ||
      !resource.startsWith(prefix)
    ) {
      continue;
    }

    // 壊れた行1つで、呼び出し側の doc(id) が全体ごと例外にならないようにする
    const id = resource.slice(prefix.length);
    if (id === "" || id.includes("/")) {
      continue;
    }

    const permissions = granted.get(id) ?? new Set();
    for (const permission of permissionsOf(role)) {
      permissions.add(permission);
    }
    granted.set(id, permissions);
  }

  // ROLES の順ではなく PERMISSIONS の順にそろえ、ロールの組み合わせで並びが変わらないようにする
  return new Map(
    [...granted].map(([id, permissions]) => [
      id,
      PERMISSIONS.filter((permission) => permissions.has(permission)),
    ]),
  );
};

/** permission を持っている、ある型のリソースの ID 一覧 */
export const resourceIdsWith = async (
  principal: Principal,
  permission: Permission,
  type: ResourceRef["type"],
): Promise<string[]> =>
  [...(await permissionsByResource(principal, type))].flatMap(
    ([id, permissions]) => (permissions.includes(permission) ? [id] : []),
  );
