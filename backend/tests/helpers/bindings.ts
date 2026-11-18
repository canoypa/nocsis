import { COLLECTION, grant } from "../../src/authz/binding.js";
import { user } from "../../src/authz/principal.js";
import { group } from "../../src/authz/resource.js";
import type { RoleName } from "../../src/authz/roles.js";
import { firestore } from "../../src/clients/firebase.js";

/** グループへの付与を作る。ロールを省くと、すべての権限を持つ admin にする */
export const grantGroup = (
  uid: string,
  groupId: string,
  role: RoleName = "roles/group.admin",
) => grant({ principal: user(uid), role, resource: group(groupId) });

/** 付与を全部消す。spec は同じ Firestore を共有するので、残すと別の spec の判定が変わる */
export const clearBindings = async () => {
  const snapshot = await firestore.collection(COLLECTION).get();
  await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
};
