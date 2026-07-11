import { z } from "zod";

/**
 * Firestore `user_joined_groups` コレクションのドキュメントスキーマ。
 *
 * これは API レスポンスの封筒である user_joined_groups.ts とは別物で、
 * uid ↔ group のメンバーシップと認可ロールを表す内部データモデル。
 *
 * `role` は後方互換のため optional。未設定のドキュメントは "member" とみなす。
 */
export const groupMembershipSchema = z.object({
  user_id: z.string(),
  group_id: z.string(),
  role: z.enum(["member", "admin"]).optional(),
});

export type GroupMembership = z.infer<typeof groupMembershipSchema>;
