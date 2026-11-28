import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";
import { verifySchedulerToken } from "../../services/scheduler_token_service.js";

// トークンの署名は scheduler_token_service.spec.ts で確かめる。Google の鍵を msw で返すと
// Firestore エミュレータ (gRPC) が止まるので、ここでは結果だけを差し替える
vi.mock("../../services/scheduler_token_service.js", () => ({
  verifySchedulerToken: vi.fn(),
}));

const GROUP_ID = "test_group_jobs";
const group = firestore.collection("groups").doc(GROUP_ID);

const finalize = (token?: string) =>
  app.request("/api/v1/jobs/dayduty-finalize", {
    method: "POST",
    headers: token ? { Authorization: `Bearer ${token}` } : {},
  });

describe("POST /jobs/dayduty-finalize", () => {
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
    await group.delete();
    await firestore.collection("classmates").doc("jobs_student").delete();
    // ほかのテストが残したグループにも書くので、すべてのグループから消す
    const days = await firestore.collectionGroup("dayduty_days").get();
    const members = await firestore.collectionGroup("dayduty_members").get();
    for (const doc of [...days.docs, ...members.docs]) await doc.ref.delete();
  });

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
