import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";
import { verifySchedulerToken } from "../../services/scheduler_token_service.js";

const { postMessage } = vi.hoisted(() => ({ postMessage: vi.fn() }));

// トークンの署名は scheduler_token_service.spec.ts で確かめる。Google の鍵を msw で返すと
// Firestore エミュレータ (gRPC) が止まるので、ここでは結果だけを差し替える
vi.mock("../../services/scheduler_token_service.js", () => ({
  verifySchedulerToken: vi.fn(),
}));
// Slack と Secret Manager は外のサービス。送ったかどうかだけを見る
vi.mock("@slack/web-api", () => ({
  WebClient: class {
    chat = { postMessage };
  },
}));
vi.mock("../../services/secret_manager_service.js", () => ({
  fetchSecret: vi.fn(async () => "slack-token"),
}));

const GROUP_ID = "test_group_jobs";
const group = firestore.collection("groups").doc(GROUP_ID);

const callJob = (path: string, token?: string) =>
  app.request(`/api/v1/jobs/${path}`, {
    method: "POST",
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });
const finalize = (token?: string) => callJob("dayduty-finalize", token);
const notify = (token?: string) => callJob("dayduty-notify", token);

describe("jobs", () => {
  beforeEach(async () => {
    await group.set({ name: "Test Group", dayduty_start_date: "2025-01-01" });
    await firestore.collection("classmates").doc("jobs_student").set({
      group_id: GROUP_ID,
      role: "student",
      stuNo: 1,
      name: "Student",
      slackUserId: "student",
    });
  });

  afterEach(async () => {
    vi.mocked(verifySchedulerToken).mockReset();
    postMessage.mockReset();
    await group.delete();
    await firestore.collection("classmates").doc("jobs_student").delete();
    // ほかのテストが残したグループにも書くので、すべてのグループから消す
    const days = await firestore.collectionGroup("dayduty_days").get();
    const members = await firestore.collectionGroup("dayduty_members").get();
    for (const doc of [...days.docs, ...members.docs]) await doc.ref.delete();
  });

  describe("POST /jobs/dayduty-finalize", () => {
    it("トークンがなければ401が返され、何も書かないこと", async () => {
      const response = await finalize();

      expect(response.status).toBe(401);
      expect((await group.collection("dayduty_days").get()).size).toBe(0);
    });

    it("ジョブ用のトークンでなければ401が返され、何も書かないこと", async () => {
      vi.mocked(verifySchedulerToken).mockResolvedValue(false);

      const response = await finalize("user-token");

      expect(response.status).toBe(401);
      expect((await group.collection("dayduty_days").get()).size).toBe(0);
    });

    it("ジョブ用のトークンなら、昨日の日直を確定すること", async () => {
      vi.mocked(verifySchedulerToken).mockResolvedValue(true);

      const response = await finalize("scheduler-token");

      expect(response.status).toBe(200);
      expect(await response.json()).toEqual({ failed: [] });
      expect(verifySchedulerToken).toHaveBeenCalledWith("scheduler-token");
      const days = await group.collection("dayduty_days").get();
      expect(days.docs.map((doc) => doc.get("members"))).toEqual([
        ["jobs_student"],
      ]);
    });
  });

  describe("POST /jobs/dayduty-notify", () => {
    it("ジョブ用のトークンでなければ401が返され、何も送らないこと", async () => {
      vi.mocked(verifySchedulerToken).mockResolvedValue(false);

      const response = await notify("user-token");

      expect(response.status).toBe(401);
      expect(postMessage).not.toHaveBeenCalled();
    });

    it("ジョブ用のトークンなら、今日の日直を知らせること", async () => {
      vi.mocked(verifySchedulerToken).mockResolvedValue(true);
      postMessage.mockResolvedValue({ ok: true });

      const response = await notify("scheduler-token");

      expect(response.status).toBe(200);
      expect(await response.json()).toEqual({ failed: [] });
      expect(postMessage).toHaveBeenCalledWith(
        expect.objectContaining({ channel: "student" }),
      );
    });
  });
});
