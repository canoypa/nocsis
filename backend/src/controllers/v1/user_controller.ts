import { Hono } from "hono";
import { describeRoute, resolver } from "hono-openapi";
import { z } from "zod";

import { resourceIdsWith } from "../../authz/check.js";
import { user } from "../../authz/principal.js";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import { skipAuthorization } from "../../middlewares/authorize.js";
import {
  userJoinedGroupSchema,
  userJoinedGroupsSchema,
} from "../../resources/v1/user_joined_groups.js";

export const userRoutes = new Hono<AuthenticatedEnv>();

type UserJoinedGroupsResponse = z.infer<typeof userJoinedGroupsSchema>;

userRoutes.use("*", authentication).get(
  "/me/groups",
  describeRoute({
    description: "自分が参加しているグループ一覧を取得する",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "application/json": { schema: resolver(userJoinedGroupsSchema) },
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

    const groupIds = await resourceIdsWith(user(uid), "group.read", "group");

    if (groupIds.length === 0) {
      return c.json<UserJoinedGroupsResponse>({ items: [] });
    }

    const groupsSnapshot = await firestore
      .collection("groups")
      .where("__name__", "in", groupIds)
      .select("name")
      .get();

    const items = z.array(userJoinedGroupSchema).parse(
      groupsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      })),
    );

    return c.json<UserJoinedGroupsResponse>({ items });
  },
);
