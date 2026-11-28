import { Hono } from "hono";
import { describeRoute, resolver, validator } from "hono-openapi";
import { HTTPException } from "hono/http-exception";
import type { z } from "zod";

import { permissionsByResource } from "../../authz/check.js";
import { user } from "../../authz/principal.js";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import { skipAuthorization } from "../../middlewares/authorize.js";
import { googleAccountPutJsonSchema, meSchema } from "../../resources/v1/me.js";
import {
  replaceGoogleAccount,
  verifyGoogleAccessToken,
} from "../../services/google_account_service.js";

export const meRoutes = new Hono<AuthenticatedEnv>();

type MeResponse = z.infer<typeof meSchema>;

/** Firebase がパスワードの変更などで再認証を求めるまでの時間に合わせる */
const RECENT_LOGIN_SECONDS = 5 * 60;

meRoutes.use("*", authentication);

meRoutes.get(
  "/",
  describeRoute({
    description: "ログインしているユーザーの、グループごとの権限を取得する",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "application/json": { schema: resolver(meSchema) },
        },
      },
      401: {
        description: "Unauthorized",
      },
      500: {
        description: "Internal Server Error",
      },
    },
    security: [{ bearer: [] }],
  }),
  skipAuthorization("自分の binding から導くので、判定するリソースが無い"),
  async (c) => {
    const uid = getCurrentUserId(c);

    const granted = await permissionsByResource(user(uid), "group");

    if (granted.size === 0) {
      return c.json<MeResponse>({ memberships: [] });
    }

    // `in` は 30 件までなので、件数に上限の無い getAll で読む
    // 並びは binding を読んだ順で決まらないよう ID 順にする。先頭が既定のグループになる
    const snapshots = await firestore.getAll(
      ...[...granted.keys()]
        .toSorted()
        .map((id) => firestore.collection("groups").doc(id)),
      { fieldMask: ["name"] },
    );

    // 消えたグループと名前の壊れたグループは返さない。1件のために全体を 500 にしない
    const memberships = snapshots.flatMap((snapshot) => {
      const permissions = granted.get(snapshot.id);

      return snapshot.exists &&
        typeof snapshot.get("name") === "string" &&
        permissions
        ? [
            {
              group: { id: snapshot.id, name: snapshot.get("name") },
              permissions,
            },
          ]
        : [];
    });

    return c.json<MeResponse>(meSchema.parse({ memberships }));
  },
);

meRoutes.put(
  "/google-account",
  describeRoute({
    description:
      "連携する Google アカウントを差し替える。まだ連携していなければ連携する",
    responses: {
      204: { description: "差し替えた" },
      400: { description: "アクセストークンが無効か、このアプリ向けではない" },
      401: { description: "Unauthorized" },
      403: {
        description:
          "匿名アカウントか、最後のログインから時間がたっている (`code` が `requires-recent-login`)",
      },
      409: {
        description:
          "その Google アカウントは別のユーザーと連携している (`code` が `linked-to-another-user`) か、差し替えの途中 (`code` が `in-progress`)",
      },
      500: { description: "Internal Server Error" },
    },
    security: [{ bearer: [] }],
  }),
  skipAuthorization("自分のアカウントだけを変える"),
  validator("json", googleAccountPutJsonSchema),
  async (c) => {
    if (c.get("signInProvider") === "anonymous") {
      throw new HTTPException(403, {
        message: "匿名アカウントには連携できません。",
      });
    }

    // 開いたままの端末や盗まれたトークンで、ログイン方法を差し替えられないようにする
    if (Date.now() / 1000 - c.get("authTime") > RECENT_LOGIN_SECONDS) {
      return c.json(
        {
          code: "requires-recent-login",
          message: "続けるには、もう一度ログインしてください。",
        },
        403,
      );
    }

    const account = await verifyGoogleAccessToken(
      c.req.valid("json").accessToken,
    );
    if (!account) {
      throw new HTTPException(400, {
        message: "Google アカウントを確認できませんでした。",
      });
    }

    const result = await replaceGoogleAccount(getCurrentUserId(c), account);
    if (!result.ok) {
      return c.json(
        result.reason === "linked_to_another_user"
          ? {
              code: "linked-to-another-user",
              message:
                "この Google アカウントはすでに別のユーザーと連携されています。",
            }
          : {
              code: "in-progress",
              message: "連携の変更を処理しています。",
            },
        409,
      );
    }

    return c.body(null, 204);
  },
);
