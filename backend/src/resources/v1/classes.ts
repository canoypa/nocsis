import { z } from "zod";

export const classSchema = z
  .object({
    // id: z.string().meta({ description: "ID" }),
    startAt: z
      .iso.datetime({ offset: true })
      .meta({ description: "開始日時" }),
    endAt: z
      .iso.datetime({ offset: true })
      .meta({ description: "終了日時" }),
    title: z.string().meta({ description: "タイトル" }),
    period: z.number().int().meta({ description: "時限" }),
  })
  .meta({
    id: "Class",
    description: "授業",
  });
