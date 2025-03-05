import { getFirestore } from "firebase-admin/firestore";
import { firebaseApp } from "~/client/firebaseApp.js";

type UserJoinedGroup = {
  user_id: string;
  group_id: string;
  group_name: string;
};

type UserJoinedGroups = {
  groups: UserJoinedGroup[];
};

type Args = {
  user_id: string;
};

const get = async ({ user_id }: Args): Promise<UserJoinedGroups> => {
  const firestore = getFirestore(firebaseApp);

  const userJoinedGroupsSnapshot = await firestore
    .collection("user_joined_groups")
    .where("user_id", "==", user_id)
    .get();

  const userJoinedGroups = userJoinedGroupsSnapshot.docs.map(
    (doc) => doc.data() as UserJoinedGroup,
  );

  return { groups: userJoinedGroups };
};
export default get;
