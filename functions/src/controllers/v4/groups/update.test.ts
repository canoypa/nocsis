import { getFirestore } from "firebase-admin/firestore";
import { functionsTest } from "tests/functions_setup.js";
import { beforeEach, describe, expect, it } from "vitest";
import { firebaseApp } from "~/client/firebaseApp.js";
import { groups } from "../index.js";

describe("update", () => {
  const groupId = "group_id";

  const beforeData = {
    name: "Group Name",

    classes_calendar_id: "classes_calendar_id",
    events_calendar_id: "events_calendar_id",

    dayduty_start_date: "2000-01-01",

    slack_event_channel_id: "slack_event_channel_id",

    weather_point: {
      lat: 0,
      lon: 0,
    },
  };

  const afterData = {
    name: "Updated Group Name",

    classes_calendar_id: "updated_classes_calendar_id",
    events_calendar_id: "updated_events_calendar_id",

    dayduty_start_date: "2099-01-01",

    slack_event_channel_id: "updated_slack_event_channel_id",

    weather_point: {
      lat: 99,
      lon: 99,
    },
  };

  const auth = functionsTest.auth.makeUserRecord({
    uid: "user_a",
  });
  const wrapped = functionsTest.wrap(groups.update);

  beforeEach(async () => {
    const firestore = getFirestore(firebaseApp);

    await firestore.doc(`groups/${groupId}`).set(beforeData);
    await firestore.collection("user_joined_groups").add({
      user_id: auth.uid,
      group_id: groupId,
    });
  });

  it("更新できること", async () => {
    await expect(
      wrapped({
        // @ts-expect-error
        auth,
        data: {
          groupId,
          data: afterData,
        },
      }),
    ).resolves.not.toThrowError();
  });

  describe("一部のデータを更新する場合", () => {
    it("更新できること", async () => {
      await expect(
        wrapped({
          // @ts-expect-error
          auth,
          data: {
            groupId,
            data: {
              name: afterData.name,
            },
          },
        }),
      ).resolves.not.toThrowError();
    });
  });

  describe("認証されていない場合", () => {
    it("エラーになること", async () => {
      await expect(
        wrapped({
          data: {
            groupId,
            data: afterData,
          },
        } as any),
      ).rejects.toThrow("You must be authenticated to use this function");
    });
  });

  describe("データが不正な場合", () => {
    describe("データが空の場合", () => {
      it("エラーになること", async () => {
        await expect(
          wrapped({
            // @ts-expect-error
            auth,
            data: {
              groupId,
              data: {},
            },
          }),
        ).rejects.toThrow("The data is invalid");
      });
    });

    describe("データの型が異なる場合", () => {
      it("エラーになること", async () => {
        await expect(
          wrapped({
            // @ts-expect-error
            auth,
            data: {
              groupId,
              data: "invalid data",
            },
          }),
        ).rejects.toThrow("The data is invalid");
      });
    });

    describe("フィールドのデータ型が異なる場合", () => {
      it("エラーになること", async () => {
        await expect(
          wrapped({
            // @ts-expect-error
            auth,
            data: {
              groupId,
              data: {
                name: 123,
              },
            },
          }),
        ).rejects.toThrow("The data is invalid");
      });
    });

    describe("存在しないフィールドが含まれる場合", () => {
      it("エラーになること", async () => {
        await expect(
          wrapped({
            // @ts-expect-error
            auth,
            data: {
              groupId,
              data: {
                invalid_field: "invalid_field",
              },
            },
          }),
        ).rejects.toThrow("The data is invalid");
      });
    });
  });

  describe("ユーザーが所属していないグループを更新しようとした場合", () => {
    it("エラーになること", async () => {
      await expect(
        wrapped({
          // @ts-expect-error
          auth: functionsTest.auth.makeUserRecord({
            uid: "user_b",
          }),
          data: {
            groupId,
            data: afterData,
          },
        }),
      ).rejects.toThrow("You must join the group to update the group");
    });
  });
});
