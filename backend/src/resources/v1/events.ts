import { z } from "zod";

import "zod-openapi/extend";

export const eventSchema = z
  .object({
    id: z.string().openapi({ description: "ID" }),
    startAt: z
      .union([z.string().date(), z.string().datetime({ offset: true })])
      .openapi({ description: "開始日時" }),
    endAt: z
      .union([z.string().date(), z.string().datetime({ offset: true })])
      .openapi({ description: "終了日時" }),
    title: z.string().openapi({ description: "タイトル" }),
    description: z.string().optional().openapi({ description: "説明" }),
    location: z.string().optional().openapi({ description: "場所" }),
    isAllDay: z.boolean().openapi({ description: "終日イベントかどうか" }),
  })
  .openapi({
    ref: "Event",
    description: "イベント",
  });
