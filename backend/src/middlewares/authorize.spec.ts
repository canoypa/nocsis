import type { DocumentReference } from "firebase-admin/firestore";
import { Hono } from "hono";
import { afterEach, describe, expect, it, vi } from "vitest";
import { firestore } from "../clients/firebase.js";
import {
  type AuthorizedEnv,
  authorize,
  getPrincipal,
  groupOf,
} from "./authorize.js";

const created: DocumentReference[] = [];

const addBinding = async (role: string) => {
  const ref = await firestore.collection("role_bindings").add({
    subject: "user:test_user_1",
    role,
    resource: "group:test_group_1",
  });
  created.push(ref);

  return ref;
};

afterEach(async () => {
  vi.restoreAllMocks();
  await Promise.all(created.splice(0).map((ref) => ref.delete()));
});

const loggedEntries = (spy: { mock: { calls: unknown[][] } }) =>
  spy.mock.calls.map(([line]) => JSON.parse(String(line)));

// authentication は済んでいる前提なので、currentUserId を直接置く
const app = new Hono<AuthorizedEnv>()
  .use("*", async (c, next) => {
    c.set("currentUserId", "test_user_1");
    await next();
  })
  .get("/groups/:id", authorize("group.update", groupOf("id")), (c) =>
    c.json({ uid: getPrincipal(c).uid }),
  );

describe("authorize", () => {
  describe("binding が1つも無い場合", () => {
    it("存在を知らせないため404になること", async () => {
      const response = await app.request("/groups/test_group_1");

      expect(response.status).toBe(404);
    });
  });

  describe("binding はあるが permission が足りない場合", () => {
    it("403になること", async () => {
      await addBinding("roles/group.viewer");

      const response = await app.request("/groups/test_group_1");

      expect(response.status).toBe(403);
    });
  });

  describe("permission を持つ場合", () => {
    it("ハンドラに進み principal が置かれていること", async () => {
      await addBinding("roles/group.admin");

      const response = await app.request("/groups/test_group_1");

      expect(response.status).toBe(200);
      expect(await response.json()).toEqual({ uid: "test_user_1" });
    });
  });

  describe("権限を持つグループと持たないグループがある場合", () => {
    it("持たない側は404になること", async () => {
      await addBinding("roles/group.admin");

      const response = await app.request("/groups/test_group_2");

      expect(response.status).toBe(404);
    });
  });

  describe("ログ", () => {
    it("拒否したときも誰が何をなぜ拒否されたかを残すこと", async () => {
      const log = vi.spyOn(console, "log").mockImplementation(() => {});
      await addBinding("roles/group.viewer");

      await app.request("/groups/test_group_1");

      expect(loggedEntries(log)).toEqual([
        {
          severity: "NOTICE",
          message: "認可しなかった",
          permission: "group.update",
          subject: "user:test_user_1",
          resource: "group:test_group_1",
          reason: "insufficient_permission",
        },
      ]);
    });

    it("許可したときはどの binding で通ったかを残すこと", async () => {
      const log = vi.spyOn(console, "log").mockImplementation(() => {});
      const ref = await addBinding("roles/group.admin");

      await app.request("/groups/test_group_1");

      expect(loggedEntries(log)).toEqual([
        {
          severity: "INFO",
          message: "認可した",
          permission: "group.update",
          subject: "user:test_user_1",
          resource: "group:test_group_1",
          via: `role_bindings/${ref.id}`,
        },
      ]);
    });
  });
});
