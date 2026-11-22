import { z } from "zod";

const eventTimeSchema = z
  .object({
    date: z
      .string()
      .date()
      .optional()
      .meta({ description: "終日の予定の日付" }),
    dateTime: z
      .string()
      .datetime({ offset: true })
      .optional()
      .meta({ description: "時刻のある予定の日時" }),
  })
  .refine(
    (time) => (time.date === undefined) !== (time.dateTime === undefined),
    { message: "date と dateTime のどちらか一方だけが必要です" },
  )
  .meta({
    $id: "EventTime",
    description: "イベントの日付か日時。どちらか一方だけが入る",
  });

export const eventSchema = z
  .object({
    id: z.string().meta({ description: "ID" }),
    startAt: z
      .union([z.string().date(), z.string().datetime({ offset: true })])
      .meta({ description: "開始日時" }),
    endAt: z
      .union([z.string().date(), z.string().datetime({ offset: true })])
      .meta({ description: "終了日時" }),
    start: eventTimeSchema,
    end: eventTimeSchema.meta({
      description: "終了。終日の予定は翌日の日付で、その日を含まない",
    }),
    title: z.string().meta({ description: "タイトル" }),
    description: z.string().optional().meta({ description: "説明" }),
    location: z.string().optional().meta({ description: "場所" }),
    isAllDay: z.boolean().meta({ description: "終日イベントかどうか" }),
  })
  .meta({
    $id: "Event",
    description: "イベント",
  });
