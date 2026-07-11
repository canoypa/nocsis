import type { DocumentData } from "firebase-admin/firestore";
import { createMiddleware } from "hono/factory";
import { HTTPException } from "hono/http-exception";
import { firestore } from "../clients/firebase.js";
import { type AuthenticatedEnv, getCurrentUserId } from "./authenticate.js";

/**
 * グループにおける認可ロール。
 * 名簿上の役割 (classmates.role: student/teacher) とは別概念として扱う。
 */
export type GroupRole = "member" | "admin";

export type GroupAuthzEnv = {
  Variables: {
    /** requireGroupMembership が取得したグループのドキュメントデータ */
    group: DocumentData;
    /** 呼び出しユーザーの当該グループにおけるロール */
    groupRole: GroupRole;
  };
};

const roleRank: Record<GroupRole, number> = {
  member: 0,
  admin: 1,
};

type RequireGroupMembershipOptions = {
  /** グループ ID を取り出すパスパラメータ名（既定: "groupId"） */
  param?: string;
  /** 要求する最低ロール（既定: "member"） */
  role?: GroupRole;
};

/**
 * 呼び出しユーザーがパスで指定されたグループのメンバーであることを検証し、
 * 必要に応じてロールを要求するミドルウェア。
 *
 * - グループが存在しない → 404
 * - グループに参加していない → 403
 * - ロールが不足している → 403
 *
 * 取得済みのグループデータと解決したロールを `group` / `groupRole` に格納する。
 * 既存の role 未設定ドキュメントは後方互換のため "member" とみなす。
 *
 * 認証 (authentication) より後に実行されることを前提とする。
 */
export const requireGroupMembership = (
  options: RequireGroupMembershipOptions = {},
) => {
  const paramName = options.param ?? "groupId";
  const requiredRole = options.role ?? "member";

  return createMiddleware<AuthenticatedEnv & GroupAuthzEnv>(async (c, next) => {
    const uid = getCurrentUserId(c);
    const groupId = c.req.param(paramName);

    if (!groupId) {
      throw new HTTPException(400, {
        message: "グループIDが指定されていません。",
      });
    }

    // Firestore 並列クエリ: グループ存在 & 参加チェック
    const [groupSnapshot, userJoinedGroupSnapshot] = await Promise.all([
      firestore.collection("groups").doc(groupId).get(),
      firestore
        .collection("user_joined_groups")
        .where("user_id", "==", uid)
        .where("group_id", "==", groupId)
        .limit(1)
        .get(),
    ]);

    if (!groupSnapshot.exists) {
      throw new HTTPException(404, { message: "グループが存在しません。" });
    }
    if (userJoinedGroupSnapshot.empty) {
      throw new HTTPException(403, {
        message: "グループに参加していません。",
      });
    }

    // role 未設定の既存ドキュメントは member として扱う（後方互換）
    const rawRole = userJoinedGroupSnapshot.docs[0].data().role;
    const role: GroupRole = rawRole === "admin" ? "admin" : "member";

    if (roleRank[role] < roleRank[requiredRole]) {
      throw new HTTPException(403, {
        message: "この操作を行う権限がありません。",
      });
    }

    const groupData = groupSnapshot.data();
    // groupSnapshot.exists が true のため data は必ず存在する
    if (!groupData) {
      throw new HTTPException(404, { message: "グループが存在しません。" });
    }

    c.set("group", { id: groupSnapshot.id, ...groupData });
    c.set("groupRole", role);

    await next();
  });
};

/**
 * 指定ロール以上を要求する requireGroupMembership の糖衣。
 */
export const requireGroupRole = (role: GroupRole, param?: string) =>
  requireGroupMembership({ role, param });
