import { getFirestore } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { getTeacher } from "./getTeacher.js";

describe("getTeacher", () => {
  const data = {
    group_id: "group_1",
    role: "teacher",
    firstName: "Foo",
    lastName: "Bar",
    slackUserId: "foobar",
  };

  beforeEach(async () => {
    const db = getFirestore(firebaseApp);
    const collection = db.collection("/classmates");

    await collection.add(data);
  });

  it("教師を取得できること", async () => {
    await expect(getTeacher("group_1")).resolves.toEqual([data]);
  });
});
