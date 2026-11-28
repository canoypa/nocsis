import { z } from "zod";

const graphemes = new Intl.Segmenter();

// max() は UTF-16 で数えるので、絵文字や濁点を合成した文字が2文字以上になる
const withinGroupNameLength = (name: string) =>
  [...graphemes.segment(name)].length <= 50;

export const groupName = z
  .string()
  .trim()
  .min(1)
  .refine(withinGroupNameLength, "名前は50文字まで");

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
