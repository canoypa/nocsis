import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute, resolver, validator } from "hono-openapi";
import { z } from "zod";
import {
  type AuthenticatedEnv,
  authentication,
} from "../../middlewares/authenticate.js";
import {
  type GroupAuthzEnv,
  requireGroupMembership,
} from "../../middlewares/authorize.js";
import { weatherDataSchema } from "../../resources/v1/weather_data.js";
import {
  fetchWeather,
  getWeatherNameById,
} from "../../services/open_weather_map_service.js";

import "zod-openapi/extend";
import { groupSchema } from "../../resources/v1/groups.js";

export const weatherRoutes = new Hono<AuthenticatedEnv & GroupAuthzEnv>();

// 認証を検証より先に実行する
weatherRoutes.use("*", authentication);

const paramSchema = z
  .object({
    groupId: z.string().openapi({ description: "グループのID" }),
  })
  .openapi({ description: "パスパラメータ" });
type WeatherDataResponse = z.infer<typeof weatherDataSchema>;

weatherRoutes.get(
  "/:groupId/weather/now",
  describeRoute({
    description: "現在の天気を取得する",
    responses: {
      200: {
        description: "Successful response",
        content: {
          "application/json": { schema: resolver(weatherDataSchema) },
        },
      },
      400: { description: "Bad Request" },
      401: { description: "Unauthorized" },
      403: { description: "Forbidden" },
      404: { description: "Not Found" },
      500: { description: "Internal Server Error" },
    },
    security: [{ bearer: [] }],
  }),
  validator("param", paramSchema),
  requireGroupMembership(),
  async (c) => {
    const parseGroup = groupSchema.safeParse(c.get("group"));
    if (!parseGroup.success) {
      throw new HTTPException(500, { message: "グループのデータが不正です。" });
    }

    const group = parseGroup.data;
    const lat = group.weather_point.lat;
    const lon = group.weather_point.lon;

    const openWeatherData = await fetchWeather({ lat, lon });

    const current = {
      temp: openWeatherData.current.temp,
      name: getWeatherNameById(openWeatherData.current.weather[0].id),
    };

    const hourly = openWeatherData.hourly.slice(0, 9).reduce(
      (p, v) => {
        p.temp.push(Math.round(v.temp));
        p.pop.push(v.pop);
        return p;
      },
      { temp: [] as number[], pop: [] as number[] },
    );

    const threeHour = openWeatherData.hourly
      .slice(1, 4)
      .map((v) => getWeatherNameById(v.weather[0].id));

    return c.json<WeatherDataResponse>({ current, hourly, threeHour });
  },
);
