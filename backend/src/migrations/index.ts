import { backfillRoleBindings } from "./backfill_role_bindings.js";
import type { Migration } from "./migration.js";

/**
 * 流せる移行の一覧。workflow から受け取った名前はここに無ければ弾くので、
 * 任意のファイルを実行させられない。
 */
export const MIGRATIONS: Record<string, Migration> = {
  backfill_role_bindings: backfillRoleBindings,
};
