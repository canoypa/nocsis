import { bindingId, COLLECTION, grant } from "../authz/binding.js";
import { subject, user } from "../authz/principal.js";
import { group, serialize } from "../authz/resource.js";
import { firestore } from "../clients/firebase.js";
import type { Migration } from "./migration.js";

/** 参加しているだけの人に付けるロール。管理や表示端末の権限は別に付与する */
export const JOINED_MEMBER_ROLE = "roles/group.viewer";

/**
 * user_joined_groups の参加を、すべて JOINED_MEMBER_ROLE の binding にする。
 *
 * 付与は3つ組で決まるので、何度流しても増えない。同じ参加が複数行あっても1つにまとまる。
 * 参加を消しても binding は外れないので、外すときは binding も消す。
 * user_joined_groups は消さない。読み手が移り切るまで両方を残す。
 */
export const backfillRoleBindings: Migration = async ({ apply }) => {
  const snapshot = await firestore
    .collection("user_joined_groups")
    .select("user_id", "group_id")
    .get();

  const counts = {
    rows: snapshot.size,
    created: 0,
    already_granted: 0,
    // user_id か group_id が文字列でない行
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
      counts.skipped++;
      continue;
    }

    const params = {
      principal: user(uid),
      role: JOINED_MEMBER_ROLE,
      resource: group(groupId),
    } as const;

    if (apply) {
      const granted = await grant(params);
      counts[granted]++;
      continue;
    }

    const existing = await firestore
      .collection(COLLECTION)
      .doc(
        bindingId(
          subject(params.principal),
          params.role,
          serialize(params.resource),
        ),
      )
      .get();
    counts[existing.exists ? "already_granted" : "created"]++;
  }

  return counts;
};
