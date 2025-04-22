import { getFirestore } from "firebase-admin/firestore";
import { DateTime } from "luxon";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { notifyDayDuty } from "./notify_dayduty.js";
import * as notifyDayDutyPerGroupModule from "./notify_dayduty_per_group.js";

describe("notifyDayduty", () => {
  beforeEach(async () => {
    const firestore = getFirestore(firebaseApp);

    await firestore.doc("groups/group_1").set({});
  });

  afterEach(async () => {
    vi.resetAllMocks();
  });

  it("正しく通知処理が呼び出されること", async () => {
    const mockedNotifyDayDutyPerGroup = vi
      .spyOn(notifyDayDutyPerGroupModule, "notifyDayDutyPerGroup")
      .mockImplementation(async () => {});

    const date = DateTime.local(2025, 1, 1);
    await notifyDayDuty(date);

    expect(mockedNotifyDayDutyPerGroup).toHaveBeenCalledTimes(1);
    expect(mockedNotifyDayDutyPerGroup).toHaveBeenCalledWith(
      { id: "group_1" },
      date,
    );
  });

  describe("通知処理でエラーが発生した場合", async () => {
    beforeEach(async () => {
      const firestore = getFirestore(firebaseApp);

      await firestore.doc("groups/group_2").set({});
    });

    it("処理は最後まで続行されること", async () => {
      const mockedNotifyDayDutyPerGroup = vi
        .spyOn(notifyDayDutyPerGroupModule, "notifyDayDutyPerGroup")
        .mockImplementationOnce(async () => {
          throw new Error("error");
        })
        .mockImplementationOnce(async () => {});

      const date = DateTime.local(2025, 1, 1);
      await notifyDayDuty(date);

      expect(mockedNotifyDayDutyPerGroup).toHaveBeenCalledTimes(2);
      expect(mockedNotifyDayDutyPerGroup).toHaveBeenCalledWith(
        { id: "group_1" },
        date,
      );
      expect(mockedNotifyDayDutyPerGroup).toHaveBeenCalledWith(
        { id: "group_2" },
        date,
      );
    });
  });
});
