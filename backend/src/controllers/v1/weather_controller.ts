import { Hono } from "hono";
import { HTTPException } from "hono/http-exception";
import { describeRoute } from "hono-openapi";
import { resolver, validator } from "hono-openapi/zod";
import { z } from "zod";
import { firestore } from "../../clients/firebase.js";
import {
  type AuthenticatedEnv,
  authentication,
  getCurrentUserId,
} from "../../middlewares/authenticate.js";
import { weatherDataSchema } from "../../resources/v1/weather_data.js";
import {
  fetchWeather,
  getWeatherNameById,
} from "../../services/open_weather_map_service.js";

import "zod-openapi/extend";
import { groupSchema } from "../../resources/v1/groups.js";

export const weatherRoutes = new Hono<AuthenticatedEnv>();

const paramSchema = z
  .object({
    groupId: z.string().openapi({ description: "グループのID" }),
  })
  .openapi({ description: "パスパラメータ" });

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
    validateResponse: true,
  }),
  validator("param", paramSchema),
  authentication,
  async (c) => {
    const groupId = c.req.param("groupId");
    const uid = getCurrentUserId(c);

    // Firestore 並列クエリ: グループ存在 & 参加チェック
    const [groupSnapshot, userJoinedGroupSnapshot] = await Promise.all([
      firestore.collection("groups").doc(groupId).get(),
      firestore
        .collection("user_joined_groups")
        .where("user_id", "==", uid)
        .where("group_id", "==", groupId)
        .get(),
    ]);
    if (!groupSnapshot.exists) {
      throw new HTTPException(404, { message: "グループが存在しません。" });
    }
    if (userJoinedGroupSnapshot.empty) {
      throw new HTTPException(403, { message: "グループに参加していません。" });
    }

    const parseGroup = groupSchema.safeParse({
      id: groupSnapshot.id,
      ...groupSnapshot.data(),
    });
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

    return c.json({ current, hourly, threeHour });
  },
);
