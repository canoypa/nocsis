import { Hono } from "hono";
import { describe, expect, it } from "vitest";
import {
  authorize,
  declarationOf,
  groupOf,
  skipAuthorization,
} from "./middlewares/authorize.js";
import { app } from "./routes.js";

/**
 * ルートごとに、認可の宣言を持つハンドラを数える。
 *
 * Hono はハンドラ1つごとに routes へ1行足すので、method と path でまとめる。
 * `use()` のミドルウェアは method が ALL の行になり、ルートではないので除く。
 */
const declarationsByRoute = (target: Hono) => {
  const routes = new Map<string, unknown[]>();

  for (const { method, path, handler } of target.routes) {
    if (method === "ALL") continue;

    const key = `${method} ${path}`;
    const declarations = routes.get(key) ?? [];
    const declaration = declarationOf(handler);
    if (declaration) declarations.push(declaration);
    routes.set(key, declarations);
  }

  return routes;
};

describe("認可の宣言", () => {
  it("すべてのルートが、permission か認可しない理由のどちらか1つを宣言している", () => {
    const routes = declarationsByRoute(app);

    // 列挙が空なら検査が素通りする
    expect(routes.size).toBeGreaterThan(0);

    const undeclared = [...routes]
      .filter(([, declarations]) => declarations.length !== 1)
      .map(([route, declarations]) => ({ route, declarations }));

    expect(undeclared).toEqual([]);
  });

  describe("検査そのもの", () => {
    it("宣言の無いルートを見つける", () => {
      const target = new Hono()
        .get("/declared", authorize("group.read", groupOf("id")), (c) =>
          c.body(null),
        )
        .get("/skipped", skipAuthorization("テスト"), (c) => c.body(null))
        .post("/forgotten", (c) => c.body(null));

      expect(declarationsByRoute(target)).toEqual(
        new Map([
          ["GET /declared", [{ kind: "permission", permission: "group.read" }]],
          ["GET /skipped", [{ kind: "skip", reason: "テスト" }]],
          ["POST /forgotten", []],
        ]),
      );
    });
  });
});
