import { HttpResponse, http } from "msw";
import { describe, expect, it } from "vitest";
import { ZodError } from "zod";
import {
  externalApiServer,
  OPEN_WEATHER_MAP_CURRENT_URL,
  OPEN_WEATHER_MAP_FORECAST_URL,
  TEST_OPENWEATHERMAP_TOKEN,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";
import {
  fetchWeather,
  getWeatherNameById,
} from "./open_weather_map_service.js";

useExternalApiServer();

describe("fetchWeather", () => {
  it("Secret Manager のトークンで現在の天気と予報を取得できること", async () => {
    const requests: URL[] = [];
    externalApiServer.use(
      http.get(OPEN_WEATHER_MAP_CURRENT_URL, ({ request }) => {
        requests.push(new URL(request.url));
        return HttpResponse.json({
          weather: [{ id: 800, main: "Clear" }],
          main: { temp: 25 },
        });
      }),
      http.get(OPEN_WEATHER_MAP_FORECAST_URL, ({ request }) => {
        requests.push(new URL(request.url));
        return HttpResponse.json({
          list: [
            {
              main: { temp: 26 },
              pop: 0.1,
              weather: [{ id: 500, main: "Rain" }],
            },
            {
              main: { temp: 27 },
              pop: 0.2,
              weather: [{ id: 600, main: "Snow" }],
            },
          ],
        });
      }),
    );

    const result = await fetchWeather({ lat: 10, lon: 20 });

    expect(result).toEqual({
      current: { temp: 25, weather: [{ id: 800, main: "Clear" }] },
      hourly: [
        { temp: 26, pop: 0.1, weather: [{ id: 500, main: "Rain" }] },
        { temp: 27, pop: 0.2, weather: [{ id: 600, main: "Snow" }] },
      ],
    });

    const [current, forecast] = requests.map((url) =>
      Object.fromEntries(url.searchParams),
    );
    expect(current).toEqual({
      appid: TEST_OPENWEATHERMAP_TOKEN,
      lat: "10",
      lon: "20",
      units: "metric",
    });
    expect(forecast).toEqual({
      appid: TEST_OPENWEATHERMAP_TOKEN,
      lat: "10",
      lon: "20",
      units: "metric",
      cnt: "8",
    });
  });

  describe("current weather API が 500 を返す場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        http.get(OPEN_WEATHER_MAP_CURRENT_URL, () =>
          HttpResponse.json(
            { cod: "500", message: "Internal Server Error" },
            { status: 500 },
          ),
        ),
      );

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
        "天気データの取得に失敗しました",
      );
    });
  });

  describe("forecast API が 500 を返す場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        http.get(OPEN_WEATHER_MAP_FORECAST_URL, () =>
          HttpResponse.json(
            { cod: "500", message: "Internal Server Error" },
            { status: 500 },
          ),
        ),
      );

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
        "天気データの取得に失敗しました",
      );
    });
  });

  describe("レスポンスの形が想定と違う場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        http.get(OPEN_WEATHER_MAP_CURRENT_URL, () =>
          HttpResponse.json({ weather: [], main: {} }),
        ),
      );

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(ZodError);
    });
  });
});

describe("getWeatherNameById", () => {
  it("雨の天候IDでRainが返されること", () => {
    expect(getWeatherNameById(200)).toBe("Rain");
    expect(getWeatherNameById(300)).toBe("Rain");
    expect(getWeatherNameById(500)).toBe("Rain");
  });

  it("雪の天候IDでSnowが返されること", () => {
    expect(getWeatherNameById(600)).toBe("Snow");
    expect(getWeatherNameById(620)).toBe("Snow");
  });

  it("大気現象の天候IDでAtmosphereが返されること", () => {
    expect(getWeatherNameById(700)).toBe("Atmosphere");
    expect(getWeatherNameById(781)).toBe("Atmosphere");
  });

  it("晴れの天候IDでClearが返されること", () => {
    expect(getWeatherNameById(800)).toBe("Clear");
    expect(getWeatherNameById(801)).toBe("Clear");
    expect(getWeatherNameById(802)).toBe("Clear");
  });

  it("曇りの天候IDでCloudsが返されること", () => {
    expect(getWeatherNameById(803)).toBe("Clouds");
    expect(getWeatherNameById(804)).toBe("Clouds");
  });

  it("不明な天候IDでUnknownが返されること", () => {
    expect(getWeatherNameById(999)).toBe("Unknown");
  });
});
