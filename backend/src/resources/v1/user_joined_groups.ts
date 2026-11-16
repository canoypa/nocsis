import { z } from "zod";
import { groupSchema } from "./groups.js";

export const userJoinedGroupSchema = groupSchema
  .pick({ id: true, name: true })
  .meta({
    $id: "UserJoinedGroup",
    description: "参加しているグループ",
  });

export const userJoinedGroupsSchema = z
  .object({
    items: z
      .array(userJoinedGroupSchema)
      .meta({ description: "参加しているグループのリスト" }),
  })
  .meta({
    $id: "UserJoinedGroups",
    description: "ユーザーが参加しているグループのリスト",
  });
