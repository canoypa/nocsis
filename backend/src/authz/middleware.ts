import assert from "node:assert";
import type { Context, MiddlewareHandler } from "hono";
import { createMiddleware } from "hono/factory";
import { HTTPException } from "hono/http-exception";
import type { AuthenticatedEnv } from "../middlewares/authenticate.js";
import { can } from "./check.js";
import { type Principal, subject, user } from "./principal.js";
import { group, type ResourceRef, serialize } from "./resource.js";
import type { Permission } from "./roles.js";

export type AuthorizedEnv = {
  Variables: AuthenticatedEnv["Variables"] & {
    principal: Principal;
  };
};

/**
 * パスパラメータからグループのリソース参照を作る resolver。
 *
 * ミドルウェアの時点ではルートのパスが型に出ないので、パラメータの存在は
 * 実行時に確かめる（ルート定義に含まれている限り必ず存在する）。
 */
export const groupOf =
  (paramName: string) =>
  (c: Context<AuthorizedEnv>): ResourceRef => {
    const id = c.req.param(paramName);
    assert(id, `パスパラメータ ${paramName} がありません`);

    return group(id);
  };

/**
 * 強制点（PEP）。`authentication` の後ろに置く。
 *
 * 404 と 403 は `reason` から派生させる。リソース型ごとの対応表は作らない
 * （エントリを1つ忘れると存在が漏れる = fail-open になる）。
 */
export const authorize = (
  permission: Permission,
  resolve: (c: Context<AuthorizedEnv>) => ResourceRef,
): MiddlewareHandler<AuthorizedEnv> =>
  createMiddleware<AuthorizedEnv>(async (c, next) => {
    const uid = c.get("currentUserId");
    assert(uid);

    const principal = user(uid);
    const resource = resolve(c);

    const decision = await can(principal, permission, resource);

    if (!decision.allowed) {
      // binding が1つも無い = そのリソースの存在を知る権利が無い → 404
      throw new HTTPException(decision.reason === "no_binding" ? 404 : 403);
    }

    // via はログにだけ。レスポンスには含めない
    console.info({
      permission,
      subject: subject(principal),
      resource: serialize(resource),
      via: decision.via,
    });

    c.set("principal", principal);

    await next();
  });

export const getPrincipal = (c: Context<AuthorizedEnv>): Principal => {
  const principal = c.get("principal");
  assert(principal);

  return principal;
};
