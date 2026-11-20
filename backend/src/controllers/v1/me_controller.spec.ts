import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { clearBindings, grantGroup } from "../../../tests/helpers/bindings.js";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";

afterEach(clearBindings);

const createGroup = (id: string, name: string) =>
  firestore
    .collection("groups")
    .doc(id)
    .set({
      name,
      classes_calendar_id: "",
      events_calendar_id: "",
      dayduty_start_date: "",
      slack_event_channel_id: "",
      weather_point: { lat: 35.0, lon: 139.0 },
    });

describe("MeController", () => {
  describe("GET /api/v1/me", () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    const getMe = () =>
      app.request("/api/v1/me", {
        headers: {
          Authorization: `Bearer ${loginResult.idToken}`,
          Accept: "application/json",
        },
      });

    beforeEach(async () => {
      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      await createGroup("test_group_1", "Test Group 1");
      await createGroup("test_group_2", "Test Group 2");
    });

    afterEach(async () => {
      await auth.deleteUser(user.uid);
      await firestore.collection("groups").doc("test_group_1").delete();
      await firestore.collection("groups").doc("test_group_2").delete();
    });

    it("グループごとに、ロールから導いた権限を返す", async () => {
      await grantGroup(user.uid, "test_group_1", "roles/group.admin");
      await grantGroup(user.uid, "test_group_2", "roles/group.viewer");

      const res = await getMe();
      const body = await res.json();

      expect(res.status).toBe(200);
      expect(body.memberships).toHaveLength(2);
      expect(body.memberships).toEqual(
        expect.arrayContaining([
          {
            group: { id: "test_group_1", name: "Test Group 1" },
            permissions: [
              "group.read",
              "group.update",
              "member.read",
              "member.create",
              "member.update",
              "member.delete",
              "access.read",
              "access.create",
              "access.delete",
            ],
          },
          {
            group: { id: "test_group_2", name: "Test Group 2" },
            permissions: ["group.read"],
          },
        ]),
      );
    });

    it("同じグループに複数のロールがあれば、権限の和を1件で返す", async () => {
      await grantGroup(user.uid, "test_group_1", "roles/group.viewer");
      await grantGroup(user.uid, "test_group_1", "roles/group.display");

      const body = await (await getMe()).json();

      expect(body.memberships).toEqual([
        {
          group: { id: "test_group_1", name: "Test Group 1" },
          permissions: ["group.read", "member.read"],
        },
      ]);
    });

    it("付与が無ければ空を返す", async () => {
      const res = await getMe();

      expect(res.status).toBe(200);
      expect(await res.json()).toEqual({ memberships: [] });
    });

    it("定義に無いロールの付与は数えない", async () => {
      await firestore.collection("role_bindings").add({
        subject: `user:${user.uid}`,
        role: "roles/group.unknown",
        resource: "group:test_group_1",
      });

      const body = await (await getMe()).json();

      expect(body).toEqual({ memberships: [] });
    });

    it("消えたグループへの付与は返さない", async () => {
      await grantGroup(user.uid, "test_group_1");
      await grantGroup(user.uid, "deleted_group");

      const body = await (await getMe()).json();

      expect(body.memberships).toEqual([
        expect.objectContaining({
          group: { id: "test_group_1", name: "Test Group 1" },
        }),
      ]);
    });

    it("名前の無いグループは返さず、ほかのグループは返す", async () => {
      await firestore.collection("groups").doc("nameless_group").set({});
      await grantGroup(user.uid, "test_group_1");
      await grantGroup(user.uid, "nameless_group");

      const res = await getMe();
      const body = await res.json();
      await firestore.collection("groups").doc("nameless_group").delete();

      expect(res.status).toBe(200);
      expect(body.memberships).toEqual([
        expect.objectContaining({
          group: { id: "test_group_1", name: "Test Group 1" },
        }),
      ]);
    });

    it("他のユーザーへの付与は返さない", async () => {
      await grantGroup("test_user_2", "test_group_1");

      const body = await (await getMe()).json();

      expect(body).toEqual({ memberships: [] });
    });

    describe("認証情報がない場合", () => {
      it("401 Unauthorized を返す", async () => {
        const res = await app.request("/api/v1/me", {
          headers: { Accept: "application/json" },
        });

        expect(res.status).toBe(401);
      });
    });
  });
});
