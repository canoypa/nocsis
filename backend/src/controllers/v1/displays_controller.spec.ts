import type { UserRecord } from "firebase-admin/auth";
import { Timestamp } from "firebase-admin/firestore";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { clearBindings, grantGroup } from "../../../tests/helpers/bindings.js";
import {
  type LoginResult,
  login,
  loginAnonymously,
} from "../../../tests/helpers/users.js";
import { can } from "../../authz/check.js";
import { user } from "../../authz/principal.js";
import { group } from "../../authz/resource.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";
import { FAILURES, PAIRINGS } from "../../services/display_service.js";

const GROUP_ID = "test_group_displays";

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

const clearCollection = async (path: string) => {
  const snapshot = await firestore.collection(path).get();
  await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
};

afterEach(async () => {
  await clearBindings();
  await clearCollection(PAIRINGS);
  await clearCollection(FAILURES);
  await clearCollection(`groups/${GROUP_ID}/displays`);
});

describe("教室ディスプレイ", () => {
  let admin: UserRecord;
  let adminLogin: LoginResult;
  let device: Awaited<ReturnType<typeof loginAnonymously>>;

  beforeEach(async () => {
    admin = await auth.createUser({ uid: "test_display_admin" });
    adminLogin = await login(admin);
    device = await loginAnonymously();
    await firestore.doc(`groups/${GROUP_ID}`).set({ name: "教室" });
    await grantGroup(admin.uid, GROUP_ID);

    return async () => {
      await auth.deleteUser(admin.uid);
      await auth.deleteUser(device.uid).catch(() => {});
      await firestore.doc(`groups/${GROUP_ID}`).delete();
    };
  });

  const issue = async () => {
    const response = await request("/api/v1/display-pairings", device.idToken, {
      method: "POST",
    });
    expect(response.status).toBe(201);

    return (await response.json()) as { code: string; expires_at: string };
  };

  const register = (code: string, name: string | null = "1年1組 黒板横") =>
    request(`/api/v1/groups/${GROUP_ID}/displays`, adminLogin.idToken, {
      method: "POST",
      body: name === null ? { code } : { code, name },
    });

  describe("POST /api/v1/display-pairings", () => {
    it("6桁のコードを10分の期限で発行すること", async () => {
      const before = Date.now();
      const { code, expires_at } = await issue();

      expect(code).toMatch(/^\d{6}$/);
      expect(Date.parse(expires_at) - before).toBeGreaterThan(9 * 60 * 1000);
      expect(Date.parse(expires_at) - before).toBeLessThanOrEqual(
        10 * 60 * 1000 + 1000,
      );
    });

    it("発行し直すと、前のコードは使えなくなること", async () => {
      const first = await issue();
      await issue();

      expect((await register(first.code)).status).toBe(404);
    });

    it("匿名でないアカウントには 403 を返すこと", async () => {
      const response = await request(
        "/api/v1/display-pairings",
        adminLogin.idToken,
        { method: "POST" },
      );

      expect(response.status).toBe(403);
    });
  });

  describe("POST /api/v1/groups/:groupId/displays", () => {
    it("端末に教室ディスプレイの権限だけが付き、コードは使い切られること", async () => {
      const { code } = await issue();

      const response = await register(code);
      const body = await response.json();

      expect(response.status).toBe(201);
      expect(body).toEqual({
        id: device.uid,
        name: "1年1組 黒板横",
        created_at: expect.any(String),
        removed_at: null,
      });

      const principal = user(device.uid);
      expect(
        (await can(principal, "member.read", group(GROUP_ID))).allowed,
      ).toBe(true);
      expect(
        (await can(principal, "group.update", group(GROUP_ID))).allowed,
      ).toBe(false);

      expect((await register(code)).status).toBe(404);
    });

    it("名前を省くか空にすると、使われていない一番小さい「ディスプレイ N」を付けること", async () => {
      const displaysOf = firestore.collection(`groups/${GROUP_ID}/displays`);
      await displaysOf
        .doc("a")
        .set({ name: "ディスプレイ 1", created_at: Timestamp.now() });
      await displaysOf
        .doc("b")
        .set({ name: "ディスプレイ 3", created_at: Timestamp.now() });
      await displaysOf
        .doc("c")
        .set({ name: "前方", created_at: Timestamp.now() });

      const first = await register((await issue()).code, null);
      expect(await first.json()).toMatchObject({ name: "ディスプレイ 2" });

      const second = await register((await issue()).code, "  ");
      expect(await second.json()).toMatchObject({ name: "ディスプレイ 2" });

      await Promise.all(
        ["a", "b", "c"].map((id) => displaysOf.doc(id).delete()),
      );
    });

    it("期限の切れたコードは 404 になること", async () => {
      const { code } = await issue();
      await firestore
        .collection(PAIRINGS)
        .doc(code)
        .update({ expires_at: Timestamp.fromMillis(Date.now() - 1000) });

      expect((await register(code)).status).toBe(404);
      expect(
        (await can(user(device.uid), "group.read", group(GROUP_ID))).allowed,
      ).toBe(false);
    });

    it("role_binding.create の無い相手には、コードを使わせないこと", async () => {
      const { code } = await issue();
      await clearBindings();
      await grantGroup(admin.uid, GROUP_ID, "roles/group.viewer");

      expect((await register(code)).status).toBe(403);
      expect(
        (await firestore.collection(PAIRINGS).doc(code).get()).exists,
      ).toBe(true);
    });

    it("コードを10回外すと、それ以降は 429 になること", async () => {
      const { code } = await issue();
      const wrong = code === "000000" ? "000001" : "000000";

      for (let i = 0; i < 10; i++) {
        expect((await register(wrong)).status).toBe(404);
      }

      expect((await register(code)).status).toBe(429);
    });

    it("発行した後にメールを結びつけたアカウントは登録しないこと", async () => {
      const { code } = await issue();
      await auth.updateUser(device.uid, { email: "device@example.com" });

      expect((await register(code)).status).toBe(404);
    });

    it("名前が50文字を超えたら 400 を返すこと", async () => {
      const { code } = await issue();

      expect((await register(code, "あ".repeat(51))).status).toBe(400);
    });

    it("絵文字や濁点を合成した文字も1文字と数えること", async () => {
      const { code } = await issue();
      const family = "👨‍👩‍👧";
      const ga = "か\u3099";

      expect((await register(code, family.repeat(51))).status).toBe(400);
      expect((await register(code, family.repeat(49) + ga)).status).toBe(201);
    });
  });

  describe("登録した後", () => {
    beforeEach(async () => {
      const { code } = await issue();
      expect((await register(code)).status).toBe(201);
    });

    it("一覧に出ること", async () => {
      const response = await request(
        `/api/v1/groups/${GROUP_ID}/displays`,
        adminLogin.idToken,
      );

      expect(await response.json()).toEqual({
        items: [
          {
            id: device.uid,
            name: "1年1組 黒板横",
            created_at: expect.any(String),
            removed_at: null,
          },
        ],
      });
    });

    describe("使われなくなって登録が解除された端末", () => {
      const removedAt = new Date("2026-11-01T00:00:00.000Z");

      beforeEach(async () => {
        await firestore
          .doc(`groups/${GROUP_ID}/displays/${device.uid}`)
          .update({ removed_at: Timestamp.fromDate(removedAt) });
      });

      it("解除された日時つきで一覧に出ること", async () => {
        const response = await request(
          `/api/v1/groups/${GROUP_ID}/displays`,
          adminLogin.idToken,
        );

        expect(await response.json()).toMatchObject({
          items: [{ id: device.uid, removed_at: removedAt.toISOString() }],
        });
      });

      it("外すと一覧から消えること", async () => {
        await auth.deleteUser(device.uid);

        const response = await request(
          `/api/v1/groups/${GROUP_ID}/displays/${device.uid}`,
          adminLogin.idToken,
          { method: "DELETE" },
        );

        expect(response.status).toBe(204);
        expect(
          (
            await firestore
              .doc(`groups/${GROUP_ID}/displays/${device.uid}`)
              .get()
          ).exists,
        ).toBe(false);
      });
    });

    it("名前を変えられること", async () => {
      const response = await request(
        `/api/v1/groups/${GROUP_ID}/displays/${device.uid}`,
        adminLogin.idToken,
        { method: "PATCH", body: { name: "2年3組 前方" } },
      );

      expect(response.status).toBe(200);
      expect(await response.json()).toMatchObject({ name: "2年3組 前方" });
    });

    it("名前は50文字まで変えられること", async () => {
      const rename = (name: string) =>
        request(
          `/api/v1/groups/${GROUP_ID}/displays/${device.uid}`,
          adminLogin.idToken,
          { method: "PATCH", body: { name } },
        );

      expect((await rename("👍".repeat(50))).status).toBe(200);
      expect((await rename("👍".repeat(51))).status).toBe(400);
    });

    it("無い教室ディスプレイの名前を変えると 404 になること", async () => {
      const response = await request(
        `/api/v1/groups/${GROUP_ID}/displays/unknown`,
        adminLogin.idToken,
        { method: "PATCH", body: { name: "2年3組 前方" } },
      );

      expect(response.status).toBe(404);
    });

    it("閲覧だけの相手は名前を変えられないこと", async () => {
      await clearBindings();
      await grantGroup(admin.uid, GROUP_ID, "roles/group.viewer");

      const response = await request(
        `/api/v1/groups/${GROUP_ID}/displays/${device.uid}`,
        adminLogin.idToken,
        { method: "PATCH", body: { name: "2年3組 前方" } },
      );

      expect(response.status).toBe(403);
    });

    it("外すと、付与も匿名アカウントも消えること", async () => {
      const response = await request(
        `/api/v1/groups/${GROUP_ID}/displays/${device.uid}`,
        adminLogin.idToken,
        { method: "DELETE" },
      );

      expect(response.status).toBe(204);
      expect(
        (await can(user(device.uid), "group.read", group(GROUP_ID))).allowed,
      ).toBe(false);
      await expect(auth.getUser(device.uid)).rejects.toMatchObject({
        code: "auth/user-not-found",
      });
    });

    it("ほかのグループにも登録されていれば、匿名アカウントは残すこと", async () => {
      await grantGroup(device.uid, "other_group", "roles/group.display");

      const response = await request(
        `/api/v1/groups/${GROUP_ID}/displays/${device.uid}`,
        adminLogin.idToken,
        { method: "DELETE" },
      );

      expect(response.status).toBe(204);
      expect((await auth.getUser(device.uid)).uid).toBe(device.uid);
    });

    it("人のアカウントは、ほかに付与が無くても消さないこと", async () => {
      const person = await auth.createUser({
        uid: "test_display_person",
        email: "person@example.com",
      });
      await firestore
        .doc(`groups/${GROUP_ID}/displays/${person.uid}`)
        .set({ name: "誤登録", created_at: Timestamp.now() });

      const response = await request(
        `/api/v1/groups/${GROUP_ID}/displays/${person.uid}`,
        adminLogin.idToken,
        { method: "DELETE" },
      );

      expect(response.status).toBe(204);
      expect((await auth.getUser(person.uid)).uid).toBe(person.uid);
      await auth.deleteUser(person.uid);
    });

    it("外した端末の発行済みコードは使えなくなること", async () => {
      const { code } = await issue();

      await request(
        `/api/v1/groups/${GROUP_ID}/displays/${device.uid}`,
        adminLogin.idToken,
        { method: "DELETE" },
      );

      expect((await register(code)).status).toBe(404);
    });

    it("閲覧だけの相手は外せないこと", async () => {
      await clearBindings();
      await grantGroup(admin.uid, GROUP_ID, "roles/group.viewer");

      const response = await request(
        `/api/v1/groups/${GROUP_ID}/displays/${device.uid}`,
        adminLogin.idToken,
        { method: "DELETE" },
      );

      expect(response.status).toBe(403);
    });
  });
});
