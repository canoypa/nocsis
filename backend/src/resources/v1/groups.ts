import { z } from "zod";

export const groupSchema = z
  .object({
    id: z.string().meta({ description: "ID" }),
    name: z.string().meta({ description: "名前" }),
    classes_calendar_id: z.string().meta({ description: "授業カレンダーID" }),
    events_calendar_id: z
      .string()
      .meta({ description: "イベントカレンダーID" }),
    dayduty_start_date: z.string().meta({ description: "日直開始日" }),
    slack_event_channel_id: z
      .string()
      .meta({ description: "Slackイベント通知チャンネルID" }),
    weather_point: z
      .object({
        lat: z.number().meta({ description: "緯度" }),
        lon: z.number().meta({ description: "経度" }),
      })
      .meta({
        $id: "WeatherPoint",
        description: "天気情報を取得する地点",
      }),
  })
  .meta({
    $id: "Group",
    description: "グループ",
  });
