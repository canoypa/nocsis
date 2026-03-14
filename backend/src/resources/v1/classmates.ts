import { z } from "zod";

export const classmateSchema = z
  .object({
    // id: z.string().meta({ description: "ID" }),
    role: z.enum(["student", "teacher"]).meta({ description: "役割" }),
    stuNo: z.number().int().meta({ description: "出席番号" }),
    name: z.string().meta({ description: "名前" }),
    email: z.email().meta({ description: "メールアドレス" }),
    slackUserId: z.string().meta({ description: "SlackユーザーID" }),
  })
  .meta({
    id: "Classmate",
    description: "クラスメイト",
  });
