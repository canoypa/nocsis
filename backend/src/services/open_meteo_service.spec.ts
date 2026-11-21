import { HttpResponse, http } from "msw";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ZodError } from "zod";
import {
  externalApiServer,
  OPEN_METEO_FORECAST_URL,
  openMeteoForecast,
  useExternalApiServer,
} from "../../tests/helpers/external_apis.js";
import {
  clearWeatherCache,
  fetchWeather,
  getWeatherNameByCode,
} from "./open_meteo_service.js";

useExternalApiServer();

beforeEach(() => {
  clearWeatherCache();
});

describe("fetchWeather", () => {
  it("現在の天気と、3時間ごと24時間先までの予報を取得できること", async () => {
    const requests: URL[] = [];
    const hours = Array.from({ length: 25 }, (_, i) => i);
    externalApiServer.use(
      http.get(OPEN_METEO_FORECAST_URL, ({ request }) => {
        requests.push(new URL(request.url));
        return HttpResponse.json({
          current: { time: 0, temperature_2m: 25, weather_code: 0 },
          hourly: {
            time: hours.map((h) => h * 3600),
            temperature_2m: hours.map((h) => 100 + h),
            precipitation_probability: hours.map((h) => h),
            weather_code: hours.map((h) => h),
          },
        });
      }),
    );

    const result = await fetchWeather({ lat: 10, lon: 20 });

    expect(result).toEqual({
      current: { temp: 25, weatherCode: 0 },
      hourly: [3, 6, 9, 12, 15, 18, 21, 24].map((h) => ({
        temp: 100 + h,
        pop: h / 100,
        weatherCode: h,
      })),
    });

    expect(requests).toHaveLength(1);
    expect(Object.fromEntries(requests[0].searchParams)).toEqual({
      latitude: "10",
      longitude: "20",
      current: "temperature_2m,weather_code",
      hourly: "temperature_2m,precipitation_probability,weather_code",
      forecast_hours: "25",
      timeformat: "unixtime",
    });
  });

  describe("降水確率が null の時刻がある場合", () => {
    it("その時刻の降水確率を 0 として扱うこと", async () => {
      externalApiServer.use(
        http.get(OPEN_METEO_FORECAST_URL, () =>
          HttpResponse.json(openMeteoForecast({ pop: null })),
        ),
      );

      const result = await fetchWeather({ lat: 1, lon: 1 });

      expect(result.hourly.map((v) => v.pop)).toEqual(Array(8).fill(0));
    });
  });

  describe("使わない時刻の気温が null の場合", () => {
    it("取得できること", async () => {
      const forecast = openMeteoForecast();
      forecast.hourly.temperature_2m[1] = null;
      externalApiServer.use(
        http.get(OPEN_METEO_FORECAST_URL, () => HttpResponse.json(forecast)),
      );

      await expect(fetchWeather({ lat: 1, lon: 1 })).resolves.toMatchObject({
        current: { temp: 20 },
      });
    });
  });

  describe("使う時刻の天気コードが null の場合", () => {
    it("エラーになること", async () => {
      const forecast = openMeteoForecast();
      forecast.hourly.weather_code[3] = null;
      externalApiServer.use(
        http.get(OPEN_METEO_FORECAST_URL, () => HttpResponse.json(forecast)),
      );

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
        "天気データの予報が足りません",
      );
    });
  });

  describe("現在の気温が null の場合", () => {
    it("エラーになること", async () => {
      const forecast = openMeteoForecast();
      externalApiServer.use(
        http.get(OPEN_METEO_FORECAST_URL, () =>
          HttpResponse.json({
            ...forecast,
            current: { ...forecast.current, temperature_2m: null },
          }),
        ),
      );

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
        "天気データの現在の値がありません",
      );
    });
  });

  describe("API が 500 を返す場合", () => {
    it("エラーになること", async () => {
      externalApiServer.use(
        http.get(OPEN_METEO_FORECAST_URL, () =>
          HttpResponse.json(
            { error: true, reason: "Internal Server Error" },
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
        http.get(OPEN_METEO_FORECAST_URL, () =>
          HttpResponse.json({ current: {}, hourly: {} }),
        ),
      );

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(ZodError);
    });
  });

  describe("予報が24時間先まで無い場合", () => {
    it("エラーになること", async () => {
      const forecast = openMeteoForecast();
      externalApiServer.use(
        http.get(OPEN_METEO_FORECAST_URL, () =>
          HttpResponse.json({
            ...forecast,
            hourly: {
              time: forecast.hourly.time.slice(0, 24),
              temperature_2m: forecast.hourly.temperature_2m.slice(0, 24),
              precipitation_probability:
                forecast.hourly.precipitation_probability.slice(0, 24),
              weather_code: forecast.hourly.weather_code.slice(0, 24),
            },
          }),
        ),
      );

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
        "天気データの予報が足りません",
      );
    });
  });
});

describe("fetchWeather のキャッシュ", () => {
  const countRequests = () => {
    const count = { forecast: 0 };
    externalApiServer.events.on("request:start", ({ request }) => {
      const { pathname } = new URL(request.url);
      if (pathname.endsWith("/forecast")) count.forecast++;
    });
    return count;
  };

  afterEach(() => {
    externalApiServer.events.removeAllListeners();
    vi.useRealTimers();
  });

  it("同じ地点を10分以内にもう一度取得しても API を呼ばないこと", async () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    const count = countRequests();

    const first = await fetchWeather({ lat: 1, lon: 1 });
    vi.advanceTimersByTime(10 * 60 * 1000 - 1);
    const second = await fetchWeather({ lat: 1, lon: 1 });

    expect(second).toEqual(first);
    expect(count).toEqual({ forecast: 1 });
  });

  it("10分経つと API から取り直すこと", async () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    const count = countRequests();

    await fetchWeather({ lat: 1, lon: 1 });
    vi.advanceTimersByTime(10 * 60 * 1000);
    await fetchWeather({ lat: 1, lon: 1 });

    expect(count).toEqual({ forecast: 2 });
  });

  it("同時に来た取得は API を1回だけ呼ぶこと", async () => {
    const count = countRequests();

    await Promise.all([
      fetchWeather({ lat: 1, lon: 1 }),
      fetchWeather({ lat: 1, lon: 1 }),
    ]);

    expect(count).toEqual({ forecast: 1 });
  });

  it("地点が違えば別々に取得すること", async () => {
    const count = countRequests();

    await fetchWeather({ lat: 1, lon: 1 });
    await fetchWeather({ lat: 1, lon: 2 });

    expect(count).toEqual({ forecast: 2 });
  });

  describe("取得に失敗した場合", () => {
    beforeEach(() => {
      externalApiServer.use(
        http.get(
          OPEN_METEO_FORECAST_URL,
          () => HttpResponse.json({}, { status: 500 }),
          { once: true },
        ),
      );
    });

    it("1分以内は API を呼ばずに同じエラーを返すこと", async () => {
      vi.useFakeTimers({ toFake: ["Date"] });
      const count = countRequests();

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
        "天気データの取得に失敗しました",
      );
      vi.advanceTimersByTime(60 * 1000 - 1);
      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
        "天気データの取得に失敗しました",
      );

      expect(count).toEqual({ forecast: 1 });
    });

    it("1分経つと API を呼び直すこと", async () => {
      vi.useFakeTimers({ toFake: ["Date"] });

      await expect(fetchWeather({ lat: 1, lon: 1 })).rejects.toThrow(
        "天気データの取得に失敗しました",
      );
      vi.advanceTimersByTime(60 * 1000);

      await expect(fetchWeather({ lat: 1, lon: 1 })).resolves.toEqual({
        current: { temp: 20, weatherCode: 0 },
        hourly: Array(8).fill({ temp: 20, pop: 0, weatherCode: 0 }),
      });
    });
  });
});

describe("getWeatherNameByCode", () => {
  it("快晴から晴れ時々曇りまでのコードで Clear が返されること", () => {
    expect(getWeatherNameByCode(0)).toBe("Clear");
    expect(getWeatherNameByCode(1)).toBe("Clear");
    expect(getWeatherNameByCode(2)).toBe("Clear");
  });

  it("曇りのコードで Clouds が返されること", () => {
    expect(getWeatherNameByCode(3)).toBe("Clouds");
  });

  it("霧のコードで Atmosphere が返されること", () => {
    expect(getWeatherNameByCode(45)).toBe("Atmosphere");
    expect(getWeatherNameByCode(48)).toBe("Atmosphere");
  });

  it("霧雨・雨・にわか雨・雷雨のコードで Rain が返されること", () => {
    for (const code of [51, 55, 56, 61, 65, 67, 80, 82, 95, 99]) {
      expect(getWeatherNameByCode(code)).toBe("Rain");
    }
  });

  it("雪・にわか雪のコードで Snow が返されること", () => {
    for (const code of [71, 75, 77, 85, 86]) {
      expect(getWeatherNameByCode(code)).toBe("Snow");
    }
  });

  it("不明なコードで Unknown が返されること", () => {
    expect(getWeatherNameByCode(999)).toBe("Unknown");
  });
});
