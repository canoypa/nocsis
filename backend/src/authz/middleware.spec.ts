import type { DocumentReference } from "firebase-admin/firestore";
import { Hono } from "hono";
import { afterEach, describe, expect, it } from "vitest";
import { firestore } from "../clients/firebase.js";
import {
  type AuthorizedEnv,
  authorize,
  getPrincipal,
  groupOf,
} from "./middleware.js";

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
  await Promise.all(created.splice(0).map((ref) => ref.delete()));
});

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
      await addBinding("group_student");

      const response = await app.request("/groups/test_group_1");

      expect(response.status).toBe(403);
    });
  });

  describe("permission を持つ場合", () => {
    it("ハンドラに進み principal が置かれていること", async () => {
      await addBinding("group_admin");

      const response = await app.request("/groups/test_group_1");

      expect(response.status).toBe(200);
      expect(await response.json()).toEqual({ uid: "test_user_1" });
    });
  });

  describe("権限を持つグループと持たないグループがある場合", () => {
    it("持たない側は404になること", async () => {
      await addBinding("group_admin");

      const response = await app.request("/groups/test_group_2");

      expect(response.status).toBe(404);
    });
  });
});
