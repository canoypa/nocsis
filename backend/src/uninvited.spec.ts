import type { UserRecord } from "firebase-admin/auth";
import {
  afterAll,
  afterEach,
  beforeAll,
  describe,
  expect,
  it,
  vi,
} from "vitest";
import { type LoginResult, login } from "../tests/helpers/users.js";
import { auth, firestore } from "./clients/firebase.js";
import { declarationOf } from "./middlewares/authorize.js";
import { app } from "./routes.js";

const GROUP_ID = "test_group_uninvited";

/** method と path ごとに、宣言が permission か skip かをまとめる */
const routesByDeclaration = () => {
  const routes = new Map<string, "permission" | "skip">();

  for (const { method, path, handler } of app.routes) {
    const kind = declarationOf(handler)?.kind;
    if (kind) routes.set(`${method} ${path}`, kind);
  }

  return [...routes].map(([route, kind]) => {
    const [method, path] = route.split(" ");
    return { route, method, path, kind };
  });
};

describe("どのグループにも招かれていないアカウント", () => {
  let user: UserRecord;
  let loginResult: LoginResult;

  beforeAll(async () => {
    user = await auth.createUser({ uid: "test_user_uninvited" });
    loginResult = await login(user);
    await firestore
      .doc(`groups/${GROUP_ID}`)
      .set({ name: "招かれていないグループ" });
  });

  afterAll(async () => {
    await auth.deleteUser(user.uid);
    await firestore.doc(`groups/${GROUP_ID}`).delete();
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  const request = (method: string, path: string) =>
    app.request(path, {
      method,
      headers: {
        Authorization: `Bearer ${loginResult.idToken}`,
        Accept: "application/json",
      },
    });

  it.each(routesByDeclaration().filter(({ kind }) => kind === "permission"))(
    "$route は、グループがあっても 404 になる",
    async ({ method, path }) => {
      const log = vi.spyOn(console, "log");

      const response = await request(
        method,
        path.replaceAll(/:\w+/g, GROUP_ID),
      );

      expect(response.status).toBe(404);
      // どのルートにも当たらなかった 404 と見分ける
      expect(log).toHaveBeenCalledWith(
        expect.stringContaining('"reason":"no_binding"'),
      );
    },
  );

  it("認可しないルートは、この一覧のものだけ", () => {
    expect(
      routesByDeclaration()
        .filter(({ kind }) => kind === "skip")
        .map(({ route }) => route)
        .sort(),
    ).toEqual(
      [
        "GET /api/v1/me",
        "GET /api/v1/users/me/groups",
        "POST /api/v1/client-errors",
        "POST /api/v1/display-pairings",
        "DELETE /api/v1/display-pairings",
        "GET /api/api-spec",
        "GET /api/api-doc",
      ].sort(),
    );
  });

  it("/v1/me は所属を返さない", async () => {
    const response = await request("GET", "/api/v1/me");

    expect(await response.json()).toEqual({ memberships: [] });
  });

  it("/v1/users/me/groups はグループを返さない", async () => {
    const response = await request("GET", "/api/v1/users/me/groups");

    expect(await response.json()).toEqual({ items: [] });
  });
});
