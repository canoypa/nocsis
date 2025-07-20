import { z } from "zod";
import { classmateSchema } from "./classmates.js";

import "zod-openapi/extend";

// Query パラメータスキーマ
export const daydudyQuerySchema = z.object({
  date: z.string().datetime({ offset: true }).optional().openapi({
    description: "日直を取得する日付（ISO形式、省略時は今日）",
    example: "2024-01-01T00:00:00+09:00",
  }),
});

// Dayduty レスポンススキーマ（直接 Classmate オブジェクト）
export const daydudyResponseSchema = classmateSchema.openapi({
  ref: "DaydudyResponse",
  description: "日直情報",
});
