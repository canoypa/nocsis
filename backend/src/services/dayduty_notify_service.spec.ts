import { FieldValue } from "firebase-admin/firestore";
import { DateTime } from "luxon";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { firestore } from "../clients/firebase.js";
import { notifyAllDayduty, notifyDayduty } from "./dayduty_notify_service.js";
import { fetchSecret } from "./secret_manager_service.js";

const { postMessage } = vi.hoisted(() => ({ postMessage: vi.fn() }));

// Slack と Secret Manager は外のサービス。Secret Manager を msw で返すと
// Firestore エミュレータ (gRPC) が止まるので、ここでは結果だけを差し替える
vi.mock("@slack/web-api", () => ({
  WebClient: class {
    chat: { postMessage: (args: unknown) => unknown };
    constructor(token: string) {
      this.chat = { postMessage: (args) => postMessage(token, args) };
    }
  },
}));
vi.mock("./secret_manager_service.js", () => ({ fetchSecret: vi.fn() }));

const GROUP_ID = "test_group_notify";
const OTHER_GROUP_ID = "test_group_notify_other";
const group = firestore.collection("groups").doc(GROUP_ID);
const otherGroup = firestore.collection("groups").doc(OTHER_GROUP_ID);

const addClassmate = (
  id: string,
  groupId: string,
  fields: { role: "student"; stuNo: number } | { role: "teacher" },
) =>
  firestore
    .collection("classmates")
    .doc(id)
    .set({
      group_id: groupId,
      name: id,
      slackUserId: `slack_${id}`,
      ...fields,
    });

const jst = (iso: string) => {
  const date = DateTime.fromISO(iso, { zone: "Asia/Tokyo" });
  if (!date.isValid) throw new Error(`無効な日付です: ${iso}`);
  return date;
};

const message = (token: string, channel: string, text: string) => [
  token,
  {
    channel,
    text,
    icon_emoji: ":bust_in_silhouette:",
    username: "今日の日直",
  },
];

describe("日直の通知", () => {
  beforeEach(async () => {
    vi.mocked(fetchSecret).mockImplementation(async (name) => `token:${name}`);
    postMessage.mockResolvedValue({ ok: true });

    await group.set({ name: "Test Group" });
    // 2025-01-01 に A が務めた
    await group
      .collection("dayduty_days")
      .doc("2025-01-01")
      .set({
        date: "2025-01-01",
        members: ["notify_A"],
        turns: { notify_A: 1, notify_B: 0 },
      });
    for (const [id, turns] of [
      ["notify_A", 1],
      ["notify_B", 0],
    ] as const) {
      await group.collection("dayduty_members").doc(id).set({ turns });
    }
    await addClassmate("notify_A", GROUP_ID, { role: "student", stuNo: 1 });
    await addClassmate("notify_B", GROUP_ID, { role: "student", stuNo: 2 });
    await addClassmate("notify_T", GROUP_ID, { role: "teacher" });

    await otherGroup.set({ name: "Other Group" });
    await addClassmate("notify_X", OTHER_GROUP_ID, {
      role: "student",
      stuNo: 1,
    });
  });

  afterEach(async () => {
    vi.mocked(fetchSecret).mockReset();
    postMessage.mockReset();
    for (const sub of ["dayduty_rules", "dayduty_days", "dayduty_members"]) {
      const docs = await group.collection(sub).get();
      for (const doc of docs.docs) await doc.ref.delete();
    }
    await group.delete();
    await otherGroup.delete();
    for (const id of ["notify_A", "notify_B", "notify_T", "notify_X"]) {
      await firestore.collection("classmates").doc(id).delete();
    }
  });

  describe("notifyDayduty", () => {
    it("その日の日直と先生に、グループの Slack で送ること", async () => {
      // 2025-01-01 の A の次なので B
      await notifyDayduty(GROUP_ID, jst("2025-01-02"));

      const token = `token:group_${GROUP_ID}-slack_token`;
      expect(postMessage.mock.calls).toEqual([
        message(token, "slack_notify_B", "今日の日直は、notify_Bさんです。"),
        message(token, "slack_notify_T", "今日の日直は、notify_Bさんです。"),
      ]);
    });

    it("送れない宛先があっても、ほかの宛先には送ってから失敗すること", async () => {
      postMessage.mockImplementation(async (_token: string, args) => {
        if (args.channel === "slack_notify_B") throw new Error("slack error");
        return { ok: true };
      });

      await expect(
        notifyDayduty(GROUP_ID, jst("2025-01-02")),
      ).rejects.toThrow();

      expect(postMessage.mock.calls.map(([, args]) => args.channel)).toEqual([
        "slack_notify_B",
        "slack_notify_T",
      ]);
    });

    it("Slack の ID がない先生は、宛先から外すこと", async () => {
      await firestore
        .collection("classmates")
        .doc("notify_T")
        .update({ slackUserId: FieldValue.delete() });

      await notifyDayduty(GROUP_ID, jst("2025-01-02"));

      expect(postMessage.mock.calls.map(([, args]) => args.channel)).toEqual([
        "slack_notify_B",
      ]);
    });

    it("トークンはキャッシュせずに読むこと", async () => {
      await notifyDayduty(GROUP_ID, jst("2025-01-02"));

      // キャッシュは Secret Manager を読む関数の中にあり、ここでは差し替えているので、渡す指定を見る
      expect(fetchSecret).toHaveBeenCalledWith(
        `group_${GROUP_ID}-slack_token`,
        {
          cache: false,
        },
      );
    });

    it("その日の日直がいなければ、送らないこと", async () => {
      for (const member of ["notify_A", "notify_B"]) {
        await group
          .collection("dayduty_rules")
          .add({ member, weekdays: [1, 2, 3, 4, 5, 6, 7] });
      }

      await notifyDayduty(GROUP_ID, jst("2025-01-02"));

      expect(postMessage).not.toHaveBeenCalled();
    });
  });

  describe("notifyAllDayduty", () => {
    const channels = () =>
      postMessage.mock.calls.map(([, args]) => args.channel as string);

    it("日本時間の今日の日直を知らせること", async () => {
      // 日本時間では 2025-01-02
      await notifyAllDayduty(jst("2025-01-01T15:30:00Z"));

      expect(channels()).toEqual(
        expect.arrayContaining(["slack_notify_B", "slack_notify_T"]),
      );
      expect(channels()).not.toContain("slack_notify_A");
    });

    it("通知を止めたグループには送らないこと", async () => {
      await group.update({ dayduty_notification_enabled: false });

      await notifyAllDayduty(jst("2025-01-01T15:30:00Z"));

      expect(channels()).not.toContain("slack_notify_B");
      expect(channels()).toContain("slack_notify_X");
    });

    it("Slack のトークンがないグループは、失敗に数えずに飛ばすこと", async () => {
      vi.mocked(fetchSecret).mockImplementation(async (name) => {
        if (name === `group_${GROUP_ID}-slack_token`)
          throw Object.assign(new Error("not found"), { code: 5 });
        return `token:${name}`;
      });

      const failed = await notifyAllDayduty(jst("2025-01-01T15:30:00Z"));

      expect(failed).not.toContain(GROUP_ID);
      expect(channels()).toContain("slack_notify_X");
    });

    it("送れなかったグループを返し、ほかのグループには送ること", async () => {
      postMessage.mockImplementation(async (token: string) => {
        if (token === `token:group_${GROUP_ID}-slack_token`)
          throw new Error("slack error");
        return { ok: true };
      });

      const failed = await notifyAllDayduty(jst("2025-01-01T15:30:00Z"));

      expect(failed).toContain(GROUP_ID);
      expect(failed).not.toContain(OTHER_GROUP_ID);
      expect(channels()).toContain("slack_notify_X");
    });
  });
});
