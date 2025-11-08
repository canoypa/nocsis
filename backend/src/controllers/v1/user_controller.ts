import { Hono } from "hono";
import { describeRoute, resolver } from "hono-openapi";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import { userJoinedGroupsSchema } from "../../resources/v1/user_joined_groups.js";

import "zod-openapi/extend";

export const userRoutes = new Hono<AuthenticatedEnv>();

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
  async (c) => {
    const uid = getCurrentUserId(c);

    const userJoinedGroupsSnapshot = await firestore
      .collection("user_joined_groups")
      .where("user_id", "==", uid)
      .get();

    // 参加しているグループIDを取得
    const groupIds = userJoinedGroupsSnapshot.docs.map(
      (doc) => doc.data().group_id,
    );

    if (groupIds.length === 0) {
      return c.json({ items: [] });
    }

    // グループの詳細情報を取得
    const groupsSnapshot = await firestore
      .collection("groups")
      .where("__name__", "in", groupIds)
      .get();

    const items = groupsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    return c.json({ items });
  },
);
