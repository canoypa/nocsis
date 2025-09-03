import { z } from "zod";

import "zod-openapi/extend";

export const classSchema = z
  .object({
    // id: z.string().openapi({ description: "ID" }),
    startAt: z
      .string()
      .datetime({ offset: true })
      .openapi({ description: "開始日時" }),
    endAt: z
      .string()
      .datetime({ offset: true })
      .openapi({ description: "終了日時" }),
    title: z.string().openapi({ description: "タイトル" }),
    period: z.number().int().openapi({ description: "時限" }),
  })
  .openapi({
    ref: "Class",
    description: "授業",
  });
