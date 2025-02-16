import { getFirestore } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { getStudentByStuNo } from "./getStudentByStuNo.js";

describe("getStudentByStuNo", () => {
  const data = {
    stuNo: 1,
    firstName: "Foo",
    lastName: "Bar",
    slackUserId: "foobar",
  };

  beforeEach(async () => {
    // FIXME: よくわからんけど、おそらくタイミング系の問題でドキュメントが見つからずエラーになるので、ここで少し遅延させる
    await new Promise((resolve) => setTimeout(resolve, 1000));

    const db = getFirestore(firebaseApp);
    const collection = db.collection("/classmates");

    await collection.add(data);
  });

  it("指定した出席番号の生徒を取得できる", async () => {
    await expect(getStudentByStuNo(1)).resolves.toEqual([data]);
  });

  it("該当するレコードがない場合、エラーが発生する", async () => {
    await expect(getStudentByStuNo(2)).rejects.toThrowError(
      "Classmate not found: 2",
    );
  });

  describe("複数指定する場合", () => {
    const data2 = {
      stuNo: 2,
      firstName: "Baz",
      lastName: "Qux",
      slackUserId: "bazqux",
    };

    beforeEach(async () => {
      const db = getFirestore(firebaseApp);
      const collection = db.collection("/classmates");

      await collection.add(data2);
    });

    it("指定した出席番号の生徒を取得できる", async () => {
      await expect(getStudentByStuNo(1, 2)).resolves.toEqual([data, data2]);
    });

    it("該当するレコードがない場合、エラーが発生する", async () => {
      await expect(getStudentByStuNo(3, 4)).rejects.toThrowError(
        "Classmate not found: 3,4",
      );
    });
  });
});
