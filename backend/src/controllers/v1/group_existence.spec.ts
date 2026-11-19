import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { clearBindings, grantGroup } from "../../../tests/helpers/bindings.js";
import { type LoginResult, login } from "../../../tests/helpers/users.js";
import { auth } from "../../clients/firebase.js";
import { app } from "../../routes.js";

// 認可はグループを読まずに決まるので、binding が残ったままグループが消えていると通ってしまう。
// そのときは各コントローラが 404 を返す。
describe("binding が残ったまま、グループが消えている場合", () => {
  let user: UserRecord;
  let loginResult: LoginResult;

  beforeEach(async () => {
    user = await auth.createUser({ uid: "test_user_deleted_group" });
    loginResult = await login(user);
    await grantGroup(user.uid, "deleted_group");
  });

  afterEach(async () => {
    await auth.deleteUser(user.uid);
    await clearBindings();
  });

  it.each([
    "/api/v1/groups/deleted_group",
    "/api/v1/groups/deleted_group/classes?from=2024-01-01T00:00:00%2B09:00&to=2024-01-02T00:00:00%2B09:00",
    "/api/v1/groups/deleted_group/events?from=2024-01-01T00:00:00%2B09:00&limit=1",
    "/api/v1/groups/deleted_group/weather/now",
    "/api/v1/groups/deleted_group/dayduty",
  ])("%s は 404 になること", async (path) => {
    const response = await app.request(path, {
      headers: {
        Authorization: `Bearer ${loginResult.idToken}`,
        Accept: "application/json",
      },
    });

    expect(response.status).toBe(404);
  });
});
