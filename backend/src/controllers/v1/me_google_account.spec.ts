import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import type { LoginResult } from "../../../tests/helpers/users.js";
import { login, loginAnonymously } from "../../../tests/helpers/users.js";
import { auth } from "../../clients/firebase.js";
import { app } from "../../routes.js";
import { verifyGoogleAccessToken } from "../../services/google_account_service.js";

vi.mock("../../services/google_account_service.js", async (importOriginal) => ({
  ...(await importOriginal<
    typeof import("../../services/google_account_service.js")
  >()),
  verifyGoogleAccessToken: vi.fn(),
}));

const googleIds = async (uid: string) =>
  (await auth.getUser(uid)).providerData
    .filter((provider) => provider.providerId === "google.com")
    .map((provider) => provider.uid);

describe("PUT /api/v1/me/google-account", () => {
  let user: UserRecord;
  let loginResult: LoginResult;

  const put = (idToken: string, body: unknown = { accessToken: "token" }) =>
    app.request("/api/v1/me/google-account", {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${idToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

  beforeEach(async () => {
    user = await auth.createUser({ uid: "test_user_1" });
    loginResult = await login(user);
    vi.mocked(verifyGoogleAccessToken).mockResolvedValue({
      id: "google_new",
      email: "new@example.com",
    });
  });

  afterEach(async () => {
    await auth.deleteUsers(["test_user_1", "test_user_2"]);
    vi.mocked(verifyGoogleAccessToken).mockReset();
  });

  it("連携している Google アカウントを差し替える", async () => {
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(204);
    expect(await googleIds(user.uid)).toEqual(["google_new"]);
  });

  it("Google を連携していなければ連携する", async () => {
    const res = await put(loginResult.idToken);

    expect(res.status).toBe(204);
    expect(await googleIds(user.uid)).toEqual(["google_new"]);
  });

  it("ほかのログイン方法は残す", async () => {
    await auth.updateUser(user.uid, {
      email: "user@example.com",
      password: "password",
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });

    await put(loginResult.idToken);

    const providers = (await auth.getUser(user.uid)).providerData.map(
      (provider) => provider.providerId,
    );
    expect(providers.sort()).toEqual(["google.com", "password"]);
  });

  it("すでに連携している同じアカウントなら、何も変えない", async () => {
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_new" },
    });

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(204);
    expect(await googleIds(user.uid)).toEqual(["google_new"]);
  });

  it("別のユーザーが連携している Google アカウントなら 409 を返し、連携を変えない", async () => {
    await auth.createUser({ uid: "test_user_2" });
    await auth.updateUser("test_user_2", {
      providerToLink: { providerId: "google.com", uid: "google_new" },
    });
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(409);
    expect(await googleIds(user.uid)).toEqual(["google_old"]);
  });

  it("アクセストークンを確認できなければ 400 を返し、連携を変えない", async () => {
    vi.mocked(verifyGoogleAccessToken).mockResolvedValue(null);
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(400);
    expect(await googleIds(user.uid)).toEqual(["google_old"]);
  });

  it("アクセストークンが無ければ 400 を返す", async () => {
    const res = await put(loginResult.idToken, {});

    expect(res.status).toBe(400);
    expect(verifyGoogleAccessToken).not.toHaveBeenCalled();
  });

  it("匿名アカウントには 403 を返す", async () => {
    const anonymous = await loginAnonymously();

    const res = await put(anonymous.idToken);

    expect(res.status).toBe(403);
    await auth.deleteUser(anonymous.localId);
  });

  it("認証情報が無ければ 401 を返す", async () => {
    const res = await app.request("/api/v1/me/google-account", {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ accessToken: "token" }),
    });

    expect(res.status).toBe(401);
  });
});
