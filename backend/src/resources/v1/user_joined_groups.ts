import { z } from "zod";
import { groupSchema } from "./groups.js";

const deprecated = <T extends z.ZodType>(schema: T) =>
  schema.optional().meta({ deprecated: true });

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
    // WeatherPoint は Group と共有の部品なので、deprecated を付けると Group 側にも付く
    weather_point: groupSchema.shape.weather_point.optional(),
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
