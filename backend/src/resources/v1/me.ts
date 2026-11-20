import { z } from "zod";
import { PERMISSIONS } from "../../authz/roles.js";
import { groupSchema } from "./groups.js";

export const permissionSchema = z.enum(PERMISSIONS).meta({
  $id: "Permission",
  description: "`<オブジェクト型>.<動作>` の形の権限",
});

export const membershipSchema = z
  .object({
    group: groupSchema
      .pick({ id: true, name: true })
      .meta({ $id: "MembershipGroup", description: "グループ" }),
    permissions: z
      .array(permissionSchema)
      .meta({ description: "このグループに対して持っている権限" }),
  })
  .meta({
    $id: "Membership",
    description: "グループと、そのグループに対して持っている権限",
  });

export const meSchema = z
  .object({
    memberships: z.array(membershipSchema).meta({
      description:
        "権限を1つでも持っているグループ。画面の出し分けに使う。判定はサーバが毎回やり直す",
    }),
  })
  .meta({
    $id: "Me",
    description: "ログインしているユーザー",
  });
