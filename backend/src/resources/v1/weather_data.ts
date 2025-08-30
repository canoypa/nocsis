import { z } from "zod";

import "zod-openapi/extend";

const WeatherNameSchema = z
  .enum(["Rain", "Snow", "Atmosphere", "Clear", "Clouds", "Unknown"])
  .openapi({ description: "天候名" });

export const weatherDataSchema = z
  .object({
    current: z
      .object({
        temp: z.number().openapi({ description: "気温" }),
        name: WeatherNameSchema.openapi({ description: "天候名" }),
      })
      .openapi({ description: "現在の天気情報" }),

    hourly: z
      .object({
        temp: z.array(z.number()).openapi({ description: "8時間先までの気温" }),
        pop: z
          .array(z.number())
          .openapi({ description: "8時間先までの降水確率" }),
      })
      .openapi({ description: "時間別天気予報" }),

    // NOTE: 本来は tuple が適切だが、swagger_dart_code_generator が正しく型を生成できないため array を使用
    threeHour: z
      .array(WeatherNameSchema)
      .length(3)
      .openapi({ description: "3時間先までの天気" }),
  })
  .openapi({
    ref: "WeatherData",
    description: "天気データ",
  });
