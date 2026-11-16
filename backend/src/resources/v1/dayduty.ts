import { z } from "zod";

export const daydutyQuerySchema = z.object({
  date: z.string().datetime({ offset: true }).optional().meta({
    description: "日直を取得する日付（ISO形式、省略時は今日）",
    example: "2024-01-01T00:00:00+09:00",
  }),
});

export const daydutyResponseSchema = z
  .object({
    name: z.string().meta({ description: "名前" }),
    // 古い frontend が読み続けているので、外す前に一度任意にして出す
    role: z
      .enum(["student", "teacher"])
      .optional()
      .meta({ description: "役割", deprecated: true }),
    stuNo: z
      .number()
      .int()
      .optional()
      .meta({ description: "出席番号", deprecated: true }),
    email: z
      .string()
      .email()
      .optional()
      .meta({ description: "メールアドレス", deprecated: true }),
    slackUserId: z
      .string()
      .optional()
      .meta({ description: "SlackユーザーID", deprecated: true }),
  })
  .meta({
    $id: "Dayduty",
    description: "日直",
  });
