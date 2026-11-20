import { Hono } from "hono";
import { describeRoute, resolver } from "hono-openapi";
import type { z } from "zod";
import { permissionsByResource } from "../../authz/check.js";
import { user } from "../../authz/principal.js";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import { meSchema } from "../../resources/v1/me.js";

export const meRoutes = new Hono<AuthenticatedEnv>();

type MeResponse = z.infer<typeof meSchema>;

meRoutes.use("*", authentication).get(
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
        .sort()
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
