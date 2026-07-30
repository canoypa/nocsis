import { z } from "zod";

export const eventSchema = z
  .object({
    id: z.string().meta({ description: "ID" }),
    startAt: z
      .union([z.string().date(), z.string().datetime({ offset: true })])
      .meta({ description: "開始日時" }),
    endAt: z
      .union([z.string().date(), z.string().datetime({ offset: true })])
      .meta({ description: "終了日時" }),
    title: z.string().meta({ description: "タイトル" }),
    description: z.string().optional().meta({ description: "説明" }),
    location: z.string().optional().meta({ description: "場所" }),
    isAllDay: z.boolean().meta({ description: "終日イベントかどうか" }),
  })
  .meta({
    $id: "Event",
    description: "イベント",
  });
