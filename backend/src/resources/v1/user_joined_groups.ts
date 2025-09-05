import { z } from "zod";
import { groupSchema } from "./groups.js";

import "zod-openapi/extend";

export const userJoinedGroupsSchema = z
  .object({
    items: z
      .array(groupSchema)
      .openapi({ description: "参加しているグループのリスト" }),
  })
  .openapi({
    ref: "UserJoinedGroups",
    description: "ユーザーが参加しているグループのリスト",
  });
