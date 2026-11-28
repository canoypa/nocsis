import type { UserRecord } from "firebase-admin/auth";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import type { LoginResult } from "../../../tests/helpers/users.js";
import { login, loginAnonymously } from "../../../tests/helpers/users.js";
import { auth, firestore } from "../../clients/firebase.js";
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
    vi.restoreAllMocks();
    await auth.deleteUsers(["test_user_1", "test_user_2"]);
    await firestore
      .collection("googleAccountSwaps")
      .doc("test_user_1")
      .delete();
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
    expect(providers.toSorted()).toEqual(["google.com", "password"]);
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

  it("確かめた後に別のユーザーが同じアカウントを連携していたら 409 を返し、元のアカウントに戻す", async () => {
    await auth.createUser({ uid: "test_user_2" });
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });
    vi.spyOn(auth, "getUserByProviderUid").mockImplementationOnce(async () => {
      // 確かめた直後に、別のユーザーが連携する
      await auth.updateUser("test_user_2", {
        providerToLink: { providerId: "google.com", uid: "google_new" },
      });
      throw Object.assign(new Error("not found"), {
        code: "auth/user-not-found",
      });
    });
    // エミュレータは連携済みのアカウントでも付けられてしまうので、本番の拒否を真似る
    const updateUser = auth.updateUser.bind(auth);
    vi.spyOn(auth, "updateUser").mockImplementation((uid, properties) =>
      uid === user.uid && properties.providerToLink?.uid === "google_new"
        ? Promise.reject(
            Object.assign(new Error("FEDERATED_USER_ID_ALREADY_LINKED"), {
              code: "auth/internal-error",
            }),
          )
        : updateUser(uid, properties),
    );

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(409);
    expect(await res.json()).toMatchObject({ code: "linked-to-another-user" });
    expect(await googleIds(user.uid)).toEqual(["google_old"]);
  });

  it("同じユーザーの差し替えが途中なら 409 を返し、連携を変えない", async () => {
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });
    await firestore
      .collection("googleAccountSwaps")
      .doc(user.uid)
      .set({ previous: { id: "google_old" } });

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(409);
    expect(await res.json()).toMatchObject({ code: "in-progress" });
    expect(await googleIds(user.uid)).toEqual(["google_old"]);
  });

  it("外すのに失敗したら、差し替えの記録を残さない", async () => {
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });
    const updateUser = auth.updateUser.bind(auth);
    vi.spyOn(auth, "updateUser").mockImplementation((uid, properties) =>
      properties.providersToUnlink
        ? Promise.reject(new Error("unavailable"))
        : updateUser(uid, properties),
    );

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(500);
    expect(await googleIds(user.uid)).toEqual(["google_old"]);
    const swap = await firestore
      .collection("googleAccountSwaps")
      .doc(user.uid)
      .get();
    expect(swap.exists).toBe(false);
  });

  // 外すのと付けるのが別の更新なので、付けられなければ Google の連携が無いまま残る
  const failLinking = (googleIds: string[]) => {
    const updateUser = auth.updateUser.bind(auth);
    vi.spyOn(auth, "updateUser").mockImplementation((uid, properties) =>
      properties.providerToLink &&
      googleIds.includes(properties.providerToLink.uid ?? "")
        ? Promise.reject(new Error("unavailable"))
        : updateUser(uid, properties),
    );
  };

  it("新しいアカウントを付けられなければ、元の Google アカウントに戻す", async () => {
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });
    failLinking(["google_new"]);

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(500);
    expect(await googleIds(user.uid)).toEqual(["google_old"]);
    const swap = await firestore
      .collection("googleAccountSwaps")
      .doc(user.uid)
      .get();
    expect(swap.exists).toBe(false);
  });

  it("元にも戻せなければ、付け直せるよう元の Google アカウントを記録に残す", async () => {
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });
    failLinking(["google_new", "google_old"]);

    const res = await put(loginResult.idToken);

    expect(res.status).toBe(500);
    expect(await googleIds(user.uid)).toEqual([]);
    const swap = await firestore
      .collection("googleAccountSwaps")
      .doc(user.uid)
      .get();
    expect(swap.get("previous.id")).toBe("google_old");
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

  it("最後のログインから5分を過ぎていたら、再認証を求めて連携を変えない", async () => {
    await auth.updateUser(user.uid, {
      providerToLink: { providerId: "google.com", uid: "google_old" },
    });
    const now = Date.now();
    vi.spyOn(Date, "now").mockReturnValue(now + 6 * 60 * 1000);

    const res = await put(loginResult.idToken);
    vi.mocked(Date.now).mockRestore();

    expect(res.status).toBe(403);
    expect(await res.json()).toMatchObject({ code: "requires-recent-login" });
    expect(verifyGoogleAccessToken).not.toHaveBeenCalled();
    expect(await googleIds(user.uid)).toEqual(["google_old"]);
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
