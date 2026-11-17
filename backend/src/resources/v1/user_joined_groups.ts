import { z } from "zod";
import { groupSchema } from "./groups.js";

// 古い frontend が読み続けているので、外す前に一度任意にして出す
export const userJoinedGroupSchema = groupSchema
  .pick({ id: true, name: true })
  .extend({
    classes_calendar_id: groupSchema.shape.classes_calendar_id
      .optional()
      .meta({ deprecated: true }),
    events_calendar_id: groupSchema.shape.events_calendar_id
      .optional()
      .meta({ deprecated: true }),
    dayduty_start_date: groupSchema.shape.dayduty_start_date
      .optional()
      .meta({ deprecated: true }),
    slack_event_channel_id: groupSchema.shape.slack_event_channel_id
      .optional()
      .meta({ deprecated: true }),
    // 共有の WeatherPoint に deprecated を付けると Group 側にも付くので、形だけ写す
    weather_point: z
      .object(groupSchema.shape.weather_point.shape)
      .optional()
      .meta({ deprecated: true }),
  })
  .meta({
    $id: "UserJoinedGroup",
    description: "参加しているグループ",
  });

export const userJoinedGroupsSchema = z
  .object({
    items: z
      .array(userJoinedGroupSchema)
      .meta({ description: "参加しているグループのリスト" }),
  })
  .meta({
    $id: "UserJoinedGroups",
    description: "ユーザーが参加しているグループのリスト",
  });
