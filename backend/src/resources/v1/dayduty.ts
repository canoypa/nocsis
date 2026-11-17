import { z } from "zod";

export const daydutyQuerySchema = z.object({
  date: z.string().datetime({ offset: true }).optional().meta({
    description: "日直を取得する日付（ISO形式、省略時は今日）",
    example: "2024-01-01T00:00:00+09:00",
  }),
});

// 古い frontend が読み続けているので、外す前に一度任意にして出す
export const daydutyResponseSchema = z
  .object({
    name: z.string().meta({ description: "名前" }),
    role: z
      .enum(["student", "teacher"])
      .meta({ description: "役割" })
      .optional()
      .meta({ deprecated: true }),
    stuNo: z
      .number()
      .int()
      .meta({ description: "出席番号" })
      .optional()
      .meta({ deprecated: true }),
    email: z
      .string()
      .email()
      .meta({ description: "メールアドレス" })
      .optional()
      .meta({ deprecated: true }),
    slackUserId: z
      .string()
      .meta({ description: "SlackユーザーID" })
      .optional()
      .meta({ deprecated: true }),
  })
  .meta({
    $id: "Dayduty",
    description: "日直",
  });
