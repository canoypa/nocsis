import type { UserRecord } from "firebase-admin/auth";
import { beforeEach, describe, expect, it } from "vitest";
import { type LoginResult, login } from "../../../tests/helpers/users.js";
import { COLLECTION, grant } from "../../authz/binding.js";
import { user as principal } from "../../authz/principal.js";
import { group } from "../../authz/resource.js";
import type { RoleName } from "../../authz/roles.js";
import { auth, firestore } from "../../clients/firebase.js";
import { app } from "../../routes.js";

const bind = (uid: string, role: RoleName, groupId: string) =>
  grant({ principal: principal(uid), role, resource: group(groupId) });

const clearBindings = async () => {
  const snapshot = await firestore.collection(COLLECTION).get();

  await Promise.all(snapshot.docs.map((doc) => doc.ref.delete()));
};

describe("GroupController", () => {
  describe("GET /api/v1/groups/:id", async () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      const groupRef = firestore.collection("groups").doc("test_group_1");

      await groupRef.set({
        name: "Test Group",
        classes_calendar_id: "classes_calendar_id",
        events_calendar_id: "events_calendar_id",
        dayduty_start_date: "2000-01-01",
        slack_event_channel_id: "slack_event_channel_id",
        weather_point: { lat: 0, lon: 0 },
      });

      await bind("test_user_1", "group_student", "test_group_1");

      return async () => {
        await auth.deleteUser("test_user_1");
        await groupRef.delete();
        await clearBindings();
      };
    });

    it("グループ情報を取得できること", async () => {
      const response = await app.request("/api/v1/groups/test_group_1", {
        headers: {
          Authorization: `Bearer ${loginResult.idToken}`,
          Accept: "application/json",
        },
      });
      const body = await response.json();

      expect(response.status).toBe(200);
      expect(body).toEqual({
        id: "test_group_1",
        name: "Test Group",
        classes_calendar_id: "classes_calendar_id",
        events_calendar_id: "events_calendar_id",
        dayduty_start_date: "2000-01-01",
        slack_event_channel_id: "slack_event_channel_id",
        weather_point: { lat: 0, lon: 0 },
      });
    });

    // 権限が無い相手に存在を漏らさないための規則。存在するグループと存在しない
    // グループが、レスポンスで区別できてはいけない
    describe("権限を持たないグループを指定した場合", () => {
      let loginResult: LoginResult;

      beforeEach(async () => {
        const outsider = await auth.createUser({
          uid: "test_user_not_in_group_1",
        });
        loginResult = await login(outsider);

        return async () => {
          await auth.deleteUser(outsider.uid);
        };
      });

      it("実在するグループでも404になること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(404);
      });

      it("存在しないグループでも404になること", async () => {
        const response = await app.request("/api/v1/groups/test_group_2", {
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(404);
      });
    });

    describe("binding はあるがグループの実体が無い場合", () => {
      beforeEach(async () => {
        await bind("test_user_1", "group_student", "test_group_2");
      });

      it("404エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_2", {
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(404);
      });
    });

    describe("認証情報がない場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          headers: {
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(401);
      });
    });

    describe("認証情報が不正な場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          headers: {
            Authorization: "Bearer invalid_token",
            Accept: "application/json",
          },
        });

        expect(response.status).toBe(401);
      });
    });
  });

  describe.todo("POST /api/v1/groups/:id", () => {});

  describe("PATCH /api/v1/groups/:id", () => {
    let user: UserRecord;
    let loginResult: LoginResult;

    beforeEach(async () => {
      user = await auth.createUser({ uid: "test_user_1" });
      loginResult = await login(user);

      const groupRef = firestore.collection("groups").doc("test_group_1");

      await groupRef.set({
        name: "Test Group",
        classes_calendar_id: "classes_calendar_id",
        events_calendar_id: "events_calendar_id",
        dayduty_start_date: "2000-01-01",
        slack_event_channel_id: "slack_event_channel_id",
        weather_point: { lat: 0, lon: 0 },
      });

      await bind("test_user_1", "group_admin", "test_group_1");

      return async () => {
        await auth.deleteUser("test_user_1");
        await groupRef.delete();
        await clearBindings();
      };
    });

    it("更新できること", async () => {
      const response = await app.request("/api/v1/groups/test_group_1", {
        method: "PATCH",
        headers: {
          Authorization: `Bearer ${loginResult.idToken}`,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify({
          name: "Updated Test Name",
          classes_calendar_id: "updated_classes_calendar_id",
          events_calendar_id: "updated_events_calendar_id",
          dayduty_start_date: "2099-12-31",
          slack_event_channel_id: "updated_slack_event_channel_id",
          weather_point: { lat: 99, lon: 99 },
        }),
      });
      const body = await response.json();

      expect(response.status).toBe(200);
      expect(body).toEqual({
        id: "test_group_1",
        name: "Updated Test Name",
        classes_calendar_id: "updated_classes_calendar_id",
        events_calendar_id: "updated_events_calendar_id",
        dayduty_start_date: "2099-12-31",
        slack_event_channel_id: "updated_slack_event_channel_id",
        weather_point: { lat: 99, lon: 99 },
      });
    });

    describe("一部のデータを更新する場合", () => {
      it("更新できること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
          }),
        });
        const body = await response.json();

        expect(response.status).toBe(200);
        expect(body).toEqual({
          id: "test_group_1",
          name: "Updated Test Name",
          classes_calendar_id: "classes_calendar_id",
          events_calendar_id: "events_calendar_id",
          dayduty_start_date: "2000-01-01",
          slack_event_channel_id: "slack_event_channel_id",
          weather_point: { lat: 0, lon: 0 },
        });
      });
    });

    describe("権限を持たないグループを指定した場合", () => {
      it("404エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_2", {
          method: "PATCH",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
          }),
        });

        expect(response.status).toBe(404);
      });
    });

    describe("binding はあるがグループの実体が無い場合", () => {
      beforeEach(async () => {
        await bind("test_user_1", "group_admin", "test_group_2");
      });

      it("404エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_2", {
          method: "PATCH",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
          }),
        });

        expect(response.status).toBe(404);
      });
    });

    describe("データが不正な場合", () => {
      describe("データが空の場合", async () => {
        it("400エラーになること", async () => {
          const response = await app.request("/api/v1/groups/test_group_1", {
            method: "PATCH",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              "Content-Type": "application/json",
              Accept: "application/json",
            },
            body: JSON.stringify({}),
          });

          expect(response.status).toBe(400);
        });
      });

      describe("データの型が異なる場合", () => {
        it("400エラーになること", async () => {
          const response = await app.request("/api/v1/groups/test_group_1", {
            method: "PATCH",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              "Content-Type": "application/json",
              Accept: "application/json",
            },
            body: JSON.stringify("invalid data"),
          });

          expect(response.status).toBe(400);
        });
      });

      describe("フィールドのデータ型が異なる場合", () => {
        it("400エラーになること", async () => {
          const response = await app.request("/api/v1/groups/test_group_1", {
            method: "PATCH",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              "Content-Type": "application/json",
              Accept: "application/json",
            },
            body: JSON.stringify({
              name: 123,
            }),
          });

          expect(response.status).toBe(400);
        });
      });

      describe("存在しないフィールドが含まれる場合", () => {
        it("400エラーになること", async () => {
          const response = await app.request("/api/v1/groups/test_group_1", {
            method: "PATCH",
            headers: {
              Authorization: `Bearer ${loginResult.idToken}`,
              "Content-Type": "application/json",
              Accept: "application/json",
            },
            body: JSON.stringify({
              invalid_field: "invalid_field",
            }),
          });

          expect(response.status).toBe(400);
        });
      });
    });

    describe("binding を持たないユーザーの場合", () => {
      let outsider: UserRecord;
      let loginResult: LoginResult;

      beforeEach(async () => {
        outsider = await auth.createUser({ uid: "test_user_not_in_group_1" });
        loginResult = await login(outsider);

        return async () => {
          await auth.deleteUser(outsider.uid);
        };
      });

      // 存在を知る権利が無いので、存在しないグループと同じ応答になる
      it("404エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({ name: "Updated Test Name" }),
        });

        expect(response.status).toBe(404);
      });
    });

    describe("読めるが更新の権限を持たないユーザーの場合", () => {
      let student: UserRecord;
      let loginResult: LoginResult;

      beforeEach(async () => {
        student = await auth.createUser({ uid: "test_user_student_1" });
        loginResult = await login(student);

        await bind("test_user_student_1", "group_student", "test_group_1");

        return async () => {
          await auth.deleteUser(student.uid);
        };
      });

      // binding はあるので存在は知っている。足りないのは group.update だけ
      it("403エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            Authorization: `Bearer ${loginResult.idToken}`,
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({ name: "Updated Test Name" }),
        });

        expect(response.status).toBe(403);
      });
    });

    describe("認証情報がない場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
            classes_calendar_id: "updated_classes_calendar_id",
            events_calendar_id: "updated_events_calendar_id",
            dayduty_start_date: "2099-12-31",
            slack_event_channel_id: "updated_slack_event_channel_id",
            weather_point: { lat: 99, lon: 99 },
          }),
        });

        expect(response.status).toBe(401);
      });
    });

    describe("認証情報が不正な場合", () => {
      it("401エラーになること", async () => {
        const response = await app.request("/api/v1/groups/test_group_1", {
          method: "PATCH",
          headers: {
            Authorization: "Bearer invalid_token",
            "Content-Type": "application/json",
            Accept: "application/json",
          },
          body: JSON.stringify({
            name: "Updated Test Name",
            classes_calendar_id: "updated_classes_calendar_id",
            events_calendar_id: "updated_events_calendar_id",
            dayduty_start_date: "2099-12-31",
            slack_event_channel_id: "updated_slack_event_channel_id",
            weather_point: { lat: 99, lon: 99 },
          }),
        });

        expect(response.status).toBe(401);
      });
    });
  });

  describe.todo("DELETE /api/v1/groups/:id", () => {});
});
