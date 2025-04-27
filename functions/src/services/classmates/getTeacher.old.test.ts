import { getFirestore } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import type { Teacher } from "~/types/classmates.js";
import { getTeacher } from "./getTeacher.old.js";

describe("getTeacher", () => {
  const data: Teacher = {
    role: "teacher",
    group_id: "group_1",
    slackUserId: "foobar",
  };

  beforeEach(async () => {
    const db = getFirestore(firebaseApp);
    const collection = db.collection("/classmates");

    await collection.add(data);
  });

  it("教師を取得できること", async () => {
    await expect(getTeacher()).resolves.toEqual([data]);
  });
});
