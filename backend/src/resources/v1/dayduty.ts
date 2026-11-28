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
    members: z
      .array(
        z.object({
          id: z.string().meta({ description: "生徒の ID" }),
          name: z.string().meta({ description: "名前" }),
        }),
      )
      .meta({ description: "その日の日直。いない日は空" }),
  })
  .meta({
    $id: "Dayduty",
    description: "日直",
  });
