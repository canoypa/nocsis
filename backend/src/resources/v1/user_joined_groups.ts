import { z } from "zod";
import { deprecated } from "../../openapi/deprecated.js";
import { groupSchema } from "./groups.js";

// 古い frontend が読み続けているので、外す前に一度任意にして出す
export const userJoinedGroupSchema = groupSchema
  .pick({ id: true, name: true })
  .extend({
    classes_calendar_id: deprecated(groupSchema.shape.classes_calendar_id),
    events_calendar_id: deprecated(groupSchema.shape.events_calendar_id),
    dayduty_start_date: deprecated(groupSchema.shape.dayduty_start_date),
    slack_event_channel_id: deprecated(
      groupSchema.shape.slack_event_channel_id,
    ),
    // 共有の WeatherPoint に deprecated を付けると Group 側にも付くので、形だけ写す
    weather_point: deprecated(z.object(groupSchema.shape.weather_point.shape)),
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
