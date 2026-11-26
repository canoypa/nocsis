import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { clearBindings, grantGroup } from "../../../tests/helpers/bindings.js";
import { type LoginResult, login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";

const GROUP_ID = "test_group_members";
const OTHER_GROUP_ID = "test_group_members_other";

type Member = { id: string; number: number; name: string };

const request = (
  path: string,
  idToken: string,
  init: { method?: string; body?: unknown } = {},
) =>
  app.request(path, {
    method: init.method ?? "GET",
    headers: {
      Authorization: `Bearer ${idToken}`,
      Accept: "application/json",
      ...(init.body ? { "Content-Type": "application/json" } : {}),
    },
    body: init.body ? JSON.stringify(init.body) : undefined,
  });

const clearClassmates = async () => {
  const snapshot = await firestore.collection("classmates").get();
  await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
};

const seedStudent = (groupId: string, stuNo: number, name: string) =>
  firestore.collection("classmates").add({
    group_id: groupId,
    role: "student",
    stuNo,
    name,
    slackUserId: `U${stuNo}`,
  });

afterEach(async () => {
  await clearBindings();
  await clearClassmates();
});

describe("生徒", () => {
  let admin: UserRecord;
  let adminLogin: LoginResult;

  const path = `/api/v1/groups/${GROUP_ID}/members`;

  const list = async () => {
    const response = await request(path, adminLogin.idToken);
    expect(response.status).toBe(200);
    return ((await response.json()) as { items: Member[] }).items;
  };

  const add = (names: unknown) =>
    request(path, adminLogin.idToken, { method: "POST", body: { names } });

  beforeEach(async () => {
    admin = await auth.createUser({ uid: "test_members_admin" });
    adminLogin = await login(admin);
    await firestore.doc(`groups/${GROUP_ID}`).set({ name: "教室" });
    await firestore.doc(`groups/${OTHER_GROUP_ID}`).set({ name: "別の教室" });
    await grantGroup(admin.uid, GROUP_ID);

    return async () => {
      await auth.deleteUser(admin.uid);
      await firestore.doc(`groups/${GROUP_ID}`).delete();
      await firestore.doc(`groups/${OTHER_GROUP_ID}`).delete();
    };
  });

  describe("GET", () => {
    it("グループの生徒だけを出席番号の順に返す", async () => {
      await seedStudent(GROUP_ID, 2, "生徒 二郎");
      await seedStudent(GROUP_ID, 1, "生徒 一郎");
      await seedStudent(OTHER_GROUP_ID, 1, "別の生徒");
      await firestore.collection("classmates").add({
        group_id: GROUP_ID,
        role: "teacher",
        slackUserId: "UT",
      });

      const members = await list();

      expect(members.map(({ number, name }) => ({ number, name }))).toEqual([
        { number: 1, name: "生徒 一郎" },
        { number: 2, name: "生徒 二郎" },
      ]);
    });

    it("member.read を持たない相手には 403 を返す", async () => {
      const viewer = await auth.createUser({ uid: "test_members_viewer" });
      const viewerLogin = await login(viewer);
      await grantGroup(viewer.uid, GROUP_ID, "roles/group.viewer");

      const response = await request(path, viewerLogin.idToken);

      expect(response.status).toBe(403);
      await auth.deleteUser(viewer.uid);
    });

    it("教室ディスプレイは読める", async () => {
      const display = await auth.createUser({ uid: "test_members_display" });
      const displayLogin = await login(display);
      await grantGroup(display.uid, GROUP_ID, "roles/group.display");

      const response = await request(path, displayLogin.idToken);

      expect(response.status).toBe(200);
      await auth.deleteUser(display.uid);
    });
  });

  describe("POST", () => {
    it("末尾の番号の続きで、名前の順に加える", async () => {
      await seedStudent(GROUP_ID, 1, "生徒 一郎");

      const response = await add([" 生徒 二郎 ", "生徒 三郎"]);

      expect(response.status).toBe(201);
      expect(
        (await list()).map(({ number, name }) => ({ number, name })),
      ).toEqual([
        { number: 1, name: "生徒 一郎" },
        { number: 2, name: "生徒 二郎" },
        { number: 3, name: "生徒 三郎" },
      ]);
    });

    it("生徒がいなければ 1 から振る", async () => {
      const response = await add(["生徒 一郎"]);

      expect(response.status).toBe(201);
      const { items } = (await response.json()) as { items: Member[] };
      expect(items.map(({ number }) => number)).toEqual([1]);
    });

    it("50文字までなら、絵文字でも受け付ける", async () => {
      expect((await add(["👨‍👩‍👧".repeat(50)])).status).toBe(201);
    });

    it.each([
      ["空の配列", []],
      ["空白だけの名前", ["  "]],
      ["51文字の名前", ["あ".repeat(51)]],
      ["101人", Array.from({ length: 101 }, (_, i) => `生徒 ${i}`)],
    ])("%sは 400 を返す", async (_, names) => {
      expect((await add(names)).status).toBe(400);
      expect(await list()).toEqual([]);
    });

    it("member.create を持たない相手には 403 を返す", async () => {
      const display = await auth.createUser({ uid: "test_members_display" });
      const displayLogin = await login(display);
      await grantGroup(display.uid, GROUP_ID, "roles/group.display");

      const response = await request(path, displayLogin.idToken, {
        method: "POST",
        body: { names: ["生徒 一郎"] },
      });

      expect(response.status).toBe(403);
      await auth.deleteUser(display.uid);
    });
  });

  describe("PATCH", () => {
    it("名前を変える", async () => {
      const ref = await seedStudent(GROUP_ID, 1, "生徒 一郎");

      const response = await request(`${path}/${ref.id}`, adminLogin.idToken, {
        method: "PATCH",
        body: { name: " 生徒 一子 " },
      });

      expect(response.status).toBe(200);
      expect(await response.json()).toEqual({
        id: ref.id,
        number: 1,
        name: "生徒 一子",
      });
    });

    it("別のグループの生徒は 404 を返す", async () => {
      const ref = await seedStudent(OTHER_GROUP_ID, 1, "別の生徒");

      const response = await request(`${path}/${ref.id}`, adminLogin.idToken, {
        method: "PATCH",
        body: { name: "書き換え" },
      });

      expect(response.status).toBe(404);
      expect((await ref.get()).get("name")).toBe("別の生徒");
    });
  });

  describe("PUT order", () => {
    const reorder = (ids: string[]) =>
      request(`${path}/order`, adminLogin.idToken, {
        method: "PUT",
        body: { ids },
      });

    it("並べた順に出席番号を振り直す", async () => {
      const one = await seedStudent(GROUP_ID, 1, "生徒 一郎");
      const two = await seedStudent(GROUP_ID, 2, "生徒 二郎");
      const three = await seedStudent(GROUP_ID, 3, "生徒 三郎");

      const response = await reorder([three.id, one.id, two.id]);

      expect(response.status).toBe(200);
      expect(
        (await list()).map(({ number, name }) => ({ number, name })),
      ).toEqual([
        { number: 1, name: "生徒 三郎" },
        { number: 2, name: "生徒 一郎" },
        { number: 3, name: "生徒 二郎" },
      ]);
    });

    it("全員がそろっていなければ、並べ替えずに 409 を返す", async () => {
      const one = await seedStudent(GROUP_ID, 1, "生徒 一郎");
      await seedStudent(GROUP_ID, 2, "生徒 二郎");

      const response = await reorder([one.id]);

      expect(response.status).toBe(409);
      expect((await list()).map(({ name }) => name)).toEqual([
        "生徒 一郎",
        "生徒 二郎",
      ]);
    });

    it("ID が重なっていたら 400 を返す", async () => {
      const one = await seedStudent(GROUP_ID, 1, "生徒 一郎");

      expect((await reorder([one.id, one.id])).status).toBe(400);
    });
  });

  describe("POST delete", () => {
    const remove = (ids: string[]) =>
      request(`${path}/delete`, adminLogin.idToken, {
        method: "POST",
        body: { ids },
      });

    it("消したあと、残りを詰めて振り直す", async () => {
      await seedStudent(GROUP_ID, 1, "生徒 一郎");
      const two = await seedStudent(GROUP_ID, 2, "生徒 二郎");
      await seedStudent(GROUP_ID, 3, "生徒 三郎");
      const four = await seedStudent(GROUP_ID, 4, "生徒 四郎");

      const response = await remove([two.id, four.id]);

      expect(response.status).toBe(200);
      expect(
        (await list()).map(({ number, name }) => ({ number, name })),
      ).toEqual([
        { number: 1, name: "生徒 一郎" },
        { number: 2, name: "生徒 三郎" },
      ]);
    });

    it("グループにいない ID があれば、何も消さずに 404 を返す", async () => {
      const one = await seedStudent(GROUP_ID, 1, "生徒 一郎");
      const other = await seedStudent(OTHER_GROUP_ID, 1, "別の生徒");

      const response = await remove([one.id, other.id]);

      expect(response.status).toBe(404);
      expect((await list()).map(({ name }) => name)).toEqual(["生徒 一郎"]);
      expect((await other.get()).exists).toBe(true);
    });
  });
});
