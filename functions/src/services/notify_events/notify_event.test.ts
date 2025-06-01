import { getFirestore } from "firebase-admin/firestore";
import { DateTime } from "luxon";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { notifyEvent } from "./notify_event.js";
import * as notifyEventPerGroupModule from "./notify_event_per_group.js";

describe("notifyEvent", () => {
  beforeEach(async () => {
    const firestore = getFirestore(firebaseApp);

    await firestore.doc("groups/group_1").set({
      slack_event_channel_id: "slack_event_channel_1",
      events_calendar_id: "events_calendar_id_1",
    });
  });

  afterEach(async () => {
    vi.resetAllMocks();
  });

  it("正しく通知処理が呼び出されること", async () => {
    const mockedNotifyEventPerGroup = vi
      .spyOn(notifyEventPerGroupModule, "notifyEventPerGroup")
      .mockImplementation(async () => {});

    const date = DateTime.local(2025, 1, 1);
    await notifyEvent(date);

    expect(mockedNotifyEventPerGroup).toHaveBeenCalledTimes(1);
    expect(mockedNotifyEventPerGroup).toHaveBeenCalledWith(
      {
        id: "group_1",
        slack_event_channel_id: "slack_event_channel_1",
        events_calendar_id: "events_calendar_id_1",
      },
      date,
    );
  });

  describe("通知処理でエラーが発生した場合", async () => {
    beforeEach(async () => {
      const firestore = getFirestore(firebaseApp);

      await firestore.doc("groups/group_2").set({
        slack_event_channel_id: "slack_event_channel_2",
        events_calendar_id: "events_calendar_id_2",
      });
    });

    it("処理は最後まで続行されること", async () => {
      const mockedNotifyEventPerGroup = vi
        .spyOn(notifyEventPerGroupModule, "notifyEventPerGroup")
        .mockImplementationOnce(async () => {
          throw new Error("error");
        })
        .mockImplementationOnce(async () => {});

      const date = DateTime.local(2025, 1, 1);
      await notifyEvent(date);

      expect(mockedNotifyEventPerGroup).toHaveBeenCalledTimes(2);
      expect(mockedNotifyEventPerGroup).toHaveBeenCalledWith(
        {
          id: "group_1",
          slack_event_channel_id: "slack_event_channel_1",
          events_calendar_id: "events_calendar_id_1",
        },
        date,
      );
      expect(mockedNotifyEventPerGroup).toHaveBeenCalledWith(
        {
          id: "group_2",
          slack_event_channel_id: "slack_event_channel_2",
          events_calendar_id: "events_calendar_id_2",
        },
        date,
      );
    });
  });
});
