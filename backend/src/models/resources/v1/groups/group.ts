import { z } from "zod";

import "zod-openapi/extend";

export const groupSchema = z
  .object({
    id: z.string().openapi({ description: "ID" }),
    name: z.string().openapi({ description: "名前" }),
    classes_calendar_id: z
      .string()
      .openapi({ description: "授業カレンダーID" }),
    events_calendar_id: z
      .string()
      .openapi({ description: "イベントカレンダーID" }),
    dayduty_start_date: z.string().openapi({ description: "日直開始日" }),
    slack_event_channel_id: z
      .string()
      .openapi({ description: "Slackイベント通知チャンネルID" }),
    weather_point: z.object({
      lat: z.number().openapi({ description: "緯度" }),
      lon: z.number().openapi({ description: "経度" }),
    }),
  })
  .openapi({ description: "グループ" });
