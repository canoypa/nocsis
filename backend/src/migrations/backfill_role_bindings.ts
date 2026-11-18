import { firestore } from "../clients/firebase.js";
import { grant } from "./binding.js";
import { user } from "./principal.js";
import { group } from "./resource.js";

/** 参加しているだけの人に付けるロール。管理や表示端末の権限は別に付与する */
export const JOINED_MEMBER_ROLE = "roles/group.viewer";

export type BackfillResult = {
  /** user_joined_groups の行数 */
  rows: number;
  created: number;
  alreadyGranted: number;
  /** user_id か group_id が文字列でない行 */
  skipped: number;
};

/**
 * user_joined_groups の参加を、すべて JOINED_MEMBER_ROLE の binding にする。
 *
 * 付与は3つ組で決まるので、何度流しても増えない。同じ参加が複数行あっても1つにまとまる。
 * user_joined_groups は消さない。読み手が移り切るまで両方を残す。
 */
export const backfillFromJoinedGroups = async (): Promise<BackfillResult> => {
  const snapshot = await firestore
    .collection("user_joined_groups")
    .select("user_id", "group_id")
    .get();

  const result: BackfillResult = {
    rows: snapshot.size,
    created: 0,
    alreadyGranted: 0,
    skipped: 0,
  };

  for (const doc of snapshot.docs) {
    const uid = doc.get("user_id");
    const groupId = doc.get("group_id");

    if (
      typeof uid !== "string" ||
      uid === "" ||
      typeof groupId !== "string" ||
      groupId === ""
    ) {
      result.skipped++;
      continue;
    }

    const granted = await grant({
      principal: user(uid),
      role: JOINED_MEMBER_ROLE,
      resource: group(groupId),
    });

    if (granted === "created") {
      result.created++;
    } else {
      result.alreadyGranted++;
    }
  }

  return result;
};
