import { getFirestore } from "firebase-admin/firestore";
import { functionsTest } from "tests/functions_setup.js";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { get } from "~/controllers/v4/groups/index.js";

describe("user_joined_group", () => {
  const wrapped = functionsTest.wrap(get);

  const userId = "user_a";
  const otherUserId = "user_b";

  const userJoinedGroup = {
    user_id: userId,
    group_id: "group_a",
    group_name: "Group A",
  };
  const otherUserJoinedGroup = {
    user_id: otherUserId,
    group_id: "group_b",
    group_name: "Group B",
  };

  beforeEach(async () => {
    const db = getFirestore(firebaseApp);
    const collection = db.collection("/user_joined_groups");

    await collection.add(userJoinedGroup);
    await collection.add(otherUserJoinedGroup);
  });

  it("参加しているグループ一覧が取得できること", async () => {
    const auth = functionsTest.auth.makeUserRecord({
      uid: userId,
    });

    // @ts-expect-error
    const result = await wrapped({ auth });

    expect(result).toEqual({
      groups: [userJoinedGroup],
    });
  });

  describe("認証されていない場合", () => {
    it("エラーを返す", async () => {
      // @ts-expect-error
      await expect(wrapped({})).rejects.toThrow(
        "You must be authenticated to use this function",
      );
    });
  });
});
