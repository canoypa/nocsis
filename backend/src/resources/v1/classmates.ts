import { z } from "zod";

import "zod-openapi/extend";

export const classmateSchema = z
  .object({
    // id: z.string().openapi({ description: "ID" }),
    role: z.enum(["student", "teacher"]).openapi({ description: "役割" }),
    stuNo: z.number().int().openapi({ description: "出席番号" }),
    name: z.string().openapi({ description: "名前" }),
    email: z.string().email().openapi({ description: "メールアドレス" }),
    slackUserId: z.string().openapi({ description: "SlackユーザーID" }),
  })
  .openapi({
    ref: "Classmate",
    description: "クラスメイト",
  });
