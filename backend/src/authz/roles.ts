import type { ResourceType } from "./resource.js";

/**
 * permission は `<オブジェクト型>.<動作>`。前半は実在するオブジェクトの型名だけで、
 * 画面名・機能名は使わない（`console.read` のような permission を作らない）。
 */
export const PERMISSIONS = [
  "group.read",
  "group.update",
  "member.read",
  "member.create",
  "member.update",
  "member.delete",
  // 権限を配る能力。招待も表示端末の登録もこれ。付けるか外すかなので update は無い
  "access.read",
  "access.create",
  "access.delete",
] as const;
export type Permission = (typeof PERMISSIONS)[number];

/**
 * ロールは permission の束。判定するコードは role を見ず permission だけを見る。
 *
 * ロール定義は DB ではなくコードに置く（型・テスト・レビュー・デプロイ履歴が効く）。
 * `scope` は単数 — 付与できるリソース型を1つに固定し、付け先違いを型エラーにする。
 */
export const ROLES = {
  group_student: {
    scope: "group",
    permissions: ["group.read"],
  },
  group_display: {
    scope: "group",
    permissions: ["group.read", "member.read"],
  },
  group_admin: {
    scope: "group",
    permissions: [
      "group.read",
      "group.update",
      "member.read",
      "member.create",
      "member.update",
      "member.delete",
      "access.read",
      "access.create",
      "access.delete",
    ],
  },
} as const satisfies Record<
  string,
  { scope: ResourceType; permissions: readonly Permission[] }
>;

export type RoleName = keyof typeof ROLES;

/**
 * Firestore から読んだロール名は信用しない。ROLES に無い名前は通さない（fail-closed）。
 */
export const isRoleName = (value: unknown): value is RoleName =>
  typeof value === "string" && Object.hasOwn(ROLES, value);

export const permissionsOf = (role: RoleName): readonly Permission[] =>
  ROLES[role].permissions;
