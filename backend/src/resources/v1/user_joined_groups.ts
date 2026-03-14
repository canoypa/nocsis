import { z } from "zod";
import { groupSchema } from "./groups.js";

export const userJoinedGroupsSchema = z
  .object({
    items: z
      .array(groupSchema)
      .meta({ description: "参加しているグループのリスト" }),
  })
  .meta({
    id: "UserJoinedGroups",
    description: "ユーザーが参加しているグループのリスト",
  });
