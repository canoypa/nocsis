import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver } from "hono-openapi";
import type { z } from "zod";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import { skipAuthorization } from "../../middlewares/authorize.js";
import { displayPairingSchema } from "../../resources/v1/displays.js";
import { cancelPairing, issuePairing } from "../../services/display_service.js";

export const displayPairingsRoutes = new Hono<AuthenticatedEnv>();

type DisplayPairingResponse = z.infer<typeof displayPairingSchema>;

displayPairingsRoutes.use("*", authentication).post(
  "/",
  describeRoute({
    description:
      "教室ディスプレイを登録するためのコードを発行する。匿名アカウントだけが使える",
    responses: {
      201: {
        description: "Created",
        content: {
          "application/json": { schema: resolver(displayPairingSchema) },
        },
      },
      401: {
        description: "Unauthorized",
      },
      403: {
        description: "匿名アカウントではない",
      },
      500: {
        description: "Internal Server Error",
      },
    },
    security: [{ bearer: [] }],
  }),
  skipAuthorization("端末が自分のために発行する。グループはまだ決まっていない"),
  async (c) => {
    // 人のアカウントに表示用の付与が付くと、外すときにアカウントを消す対象と見分けにくくなる
    if (c.get("signInProvider") !== "anonymous") {
      throw new HTTPException(403, {
        message: "匿名アカウントでだけ発行できます。",
      });
    }

    const pairing = await issuePairing(getCurrentUserId(c));

    return c.json<DisplayPairingResponse>(pairing, 201);
  },
);

displayPairingsRoutes.delete(
  "/",
  describeRoute({
    description:
      "教室ディスプレイの登録をやめる。発行したコードと匿名アカウントを消す。匿名アカウントだけが使える",
    responses: {
      204: {
        description: "No Content",
      },
      401: {
        description: "Unauthorized",
      },
      403: {
        description: "匿名アカウントではない",
      },
      409: {
        description: "もう登録されている",
      },
      500: {
        description: "Internal Server Error",
      },
    },
    security: [{ bearer: [] }],
  }),
  skipAuthorization("端末が自分のコードとアカウントを消す"),
  async (c) => {
    if (c.get("signInProvider") !== "anonymous") {
      throw new HTTPException(403, {
        message: "匿名アカウントでだけやめられます。",
      });
    }

    const result = await cancelPairing(getCurrentUserId(c));
    if (result === "registered") {
      throw new HTTPException(409, { message: "もう登録されています。" });
    }

    return c.body(null, 204);
  },
);
