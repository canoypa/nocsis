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
 * 認可の宣言が無い、または効かない位置にあるルートを返す。
 *
 * Hono はハンドラ1つごとに routes へ1行足すので、method と path でまとめる。
 * 宣言は1つだけで、最後のハンドラ（レスポンスを返す）より前に無いと効かない。
 * `use()` のミドルウェアは method が ALL で path が `*` で終わる行になり、ルートではないので除く。
 * `all()` のルートは `*` で終わらない限り検査する。
 */
const undeclaredRoutes = (target: Hono) => {
  const routes = new Map<string, unknown[]>();

  for (const { method, path, handler } of target.routes) {
    if (method === "ALL" && path.endsWith("*")) continue;

    const key = `${method} ${path}`;
    routes.set(key, [...(routes.get(key) ?? []), handler]);
  }

  return [...routes].flatMap(([route, handlers]) => {
    const declared = handlers.flatMap((handler, index) =>
      declarationOf(handler) ? [index] : [],
    );

    return declared.length === 1 && declared[0] < handlers.length - 1
      ? []
      : [route];
  });
};

describe("認可の宣言", () => {
  it("すべてのルートが、permission か認可しない理由のどちらか1つを宣言している", () => {
    // 列挙が空なら検査が素通りする
    expect(app.routes.length).toBeGreaterThan(0);

    expect(undeclaredRoutes(app)).toEqual([]);
  });

  describe("検査そのもの", () => {
    const ok = () => new Response(null);

    it("宣言のあるルートは通す", () => {
      const target = new Hono()
        .use("*", async (_c, next) => next())
        .get("/declared", authorize("group.read", groupOf("id")), ok)
        .get("/skipped", skipAuthorization("テスト"), ok);

      expect(undeclaredRoutes(target)).toEqual([]);
    });

    it("宣言の無いルートを見つける", () => {
      const target = new Hono().post("/forgotten", ok).all("/any", ok);

      expect(undeclaredRoutes(target)).toEqual(["POST /forgotten", "ALL /any"]);
    });

    it("宣言がレスポンスを返すハンドラより後ろにあるルートを見つける", () => {
      const target = new Hono().get(
        "/late",
        ok,
        authorize("group.read", groupOf("id")),
      );

      expect(undeclaredRoutes(target)).toEqual(["GET /late"]);
    });

    it("宣言が2つあるルートを見つける", () => {
      const target = new Hono().get(
        "/twice",
        skipAuthorization("テスト"),
        authorize("group.read", groupOf("id")),
        ok,
      );

      expect(undeclaredRoutes(target)).toEqual(["GET /twice"]);
    });

    it("onError のあるサブアプリでも宣言を読める", () => {
      const sub = new Hono()
        .get("/declared", authorize("group.read", groupOf("id")), ok)
        .onError((_error, c) => c.body(null, 500));
      const target = new Hono().route("/sub", sub);

      expect(undeclaredRoutes(target)).toEqual([]);
    });
  });
});
