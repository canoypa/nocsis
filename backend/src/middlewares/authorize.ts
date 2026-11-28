import assert from "node:assert";

import type { Context, MiddlewareHandler } from "hono";
import { createMiddleware } from "hono/factory";
import { HTTPException } from "hono/http-exception";
import { COMPOSED_HANDLER } from "hono/utils/constants";

import { can } from "../authz/check.js";
import { type Principal, subject, user } from "../authz/principal.js";
import { group, type ResourceRef, serialize } from "../authz/resource.js";
import type { Permission } from "../authz/roles.js";
import type { AuthenticatedEnv } from "./authenticate.js";

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
 * ルートが認可をどう宣言したか。付け忘れの検査（routes.spec.ts）が読む。
 * ミドルウェアは関数なので、関数そのものに紐付けて持つ。
 */
export type AuthorizationDeclaration =
  | { kind: "permission"; permission: Permission }
  | { kind: "skip"; reason: string };

const declarations = new WeakMap<object, AuthorizationDeclaration>();

export const declarationOf = (
  handler: unknown,
): AuthorizationDeclaration | undefined => {
  if (typeof handler !== "function") return undefined;

  // サブアプリに onError があると、route() はハンドラを包み、元を COMPOSED_HANDLER に置く
  const original: unknown = Reflect.get(handler, COMPOSED_HANDLER) ?? handler;

  return typeof original === "function"
    ? declarations.get(original)
    : undefined;
};

/**
 * リソースへの認可を行わないことの宣言。何もしない。
 * 「自分の binding から導く」のように、判定する相手が先に決まっていないルートに置く。
 */
export const skipAuthorization = (reason: string): MiddlewareHandler => {
  const middleware = createMiddleware(async (_c, next) => {
    await next();
  });
  declarations.set(middleware, { kind: "skip", reason });

  return middleware;
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
): MiddlewareHandler<AuthorizedEnv> => {
  const middleware = createMiddleware<AuthorizedEnv>(async (c, next) => {
    const uid = c.get("currentUserId");
    assert(uid);

    const principal = user(uid);
    const resource = resolve(c);

    const decision = await can(principal, permission, resource);

    // via はログにだけ。レスポンスには含めない。
    // Cloud Logging に jsonPayload として渡すため、行全体を JSON にする
    // （severity は console のメソッドではなくこのフィールドで決まる）
    console.log(
      JSON.stringify({
        severity: decision.allowed ? "INFO" : "NOTICE",
        message: decision.allowed ? "認可した" : "認可しなかった",
        permission,
        subject: subject(principal),
        resource: serialize(resource),
        ...(decision.allowed
          ? { via: decision.via }
          : { reason: decision.reason }),
      }),
    );

    if (!decision.allowed) {
      // binding が1つも無い = そのリソースの存在を知る権利が無い → 404
      throw new HTTPException(decision.reason === "no_binding" ? 404 : 403);
    }

    c.set("principal", principal);

    await next();
  });
  declarations.set(middleware, { kind: "permission", permission });

  return middleware;
};

export const getPrincipal = (c: Context<AuthorizedEnv>): Principal => {
  const principal = c.get("principal");
  assert(principal);

  return principal;
};
