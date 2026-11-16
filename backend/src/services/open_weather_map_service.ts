import { z } from "zod";
import { fetchSecret } from "./secret_manager_service.js";

export type WeatherData = {
  current: { temp: number; weather: { id: number; main: string }[] };
  hourly: {
    temp: number;
    pop: number;
    weather: { id: number; main: string }[];
  }[];
};

interface FetchWeatherParams {
  lat: number;
  lon: number;
}

const CurrentWeatherResponseSchema = z.object({
  weather: z.array(z.object({ id: z.number(), main: z.string() })),
  main: z.object({ temp: z.number() }),
});
const ForecastWeatherResponseSchema = z.object({
  list: z.array(
    z.object({
      main: z.object({ temp: z.number() }),
      pop: z.number(),
      weather: z.array(z.object({ id: z.number(), main: z.string() })),
    }),
  ),
});

const CURRENT_WEATHER_ENDPOINT =
  "https://api.openweathermap.org/data/2.5/weather";
const FIVE_DAY_WEATHER_FORECAST_ENDPOINT =
  "https://api.openweathermap.org/data/2.5/forecast";

const CACHE_TTL_MS = 10 * 60 * 1000;
const FAILURE_CACHE_TTL_MS = 60 * 1000;
const FETCH_TIMEOUT_MS = 10 * 1000;

const cache = new Map<
  string,
  { expiresAt: number; data: Promise<WeatherData> }
>();

/**
 * 天気情報を地点ごとにキャッシュして返す
 */
export const fetchWeather = (
  params: FetchWeatherParams,
): Promise<WeatherData> => {
  const key = `${params.lat},${params.lon}`;
  const now = Date.now();

  const hit = cache.get(key);
  if (hit && hit.expiresAt > now) return hit.data;

  const data = fetchWeatherFromApi(params);
  const entry = { expiresAt: now + CACHE_TTL_MS, data };
  cache.set(key, entry);
  // 失敗を TTL いっぱい残すと復旧後も長くエラーを返し、すぐ消すと API が制限中でも呼び続ける
  data.catch(() => {
    entry.expiresAt = Math.min(
      entry.expiresAt,
      Date.now() + FAILURE_CACHE_TTL_MS,
    );
  });

  return data;
};

/**
 * テスト用: 天気のキャッシュを空にする
 */
export const clearWeatherCache = (): void => {
  cache.clear();
};

/**
 * OpenWeatherMap API から天気情報を取得する
 */
const fetchWeatherFromApi = async ({
  lat,
  lon,
}: FetchWeatherParams): Promise<WeatherData> => {
  const token = await fetchSecret("OPENWEATHERMAP_TOKEN");

  const currentWeatherApiUrl = new URL(CURRENT_WEATHER_ENDPOINT);
  currentWeatherApiUrl.searchParams.set("appid", token);
  currentWeatherApiUrl.searchParams.set("lat", lat.toString());
  currentWeatherApiUrl.searchParams.set("lon", lon.toString());
  currentWeatherApiUrl.searchParams.set("units", "metric");

  const forecastApiUrl = new URL(FIVE_DAY_WEATHER_FORECAST_ENDPOINT);
  forecastApiUrl.searchParams.set("appid", token);
  forecastApiUrl.searchParams.set("lat", lat.toString());
  forecastApiUrl.searchParams.set("lon", lon.toString());
  forecastApiUrl.searchParams.set("units", "metric");
  forecastApiUrl.searchParams.set("cnt", "8");

  const [currentRes, forecastRes] = await Promise.all([
    fetch(currentWeatherApiUrl, {
      signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
    }),
    fetch(forecastApiUrl, { signal: AbortSignal.timeout(FETCH_TIMEOUT_MS) }),
  ]);

  if (!currentRes.ok || !forecastRes.ok) {
    throw new Error("天気データの取得に失敗しました");
  }

  const currentJson = await currentRes.json();
  const currentData = CurrentWeatherResponseSchema.parse(currentJson);
  const forecastJson = await forecastRes.json();
  const forecastData = ForecastWeatherResponseSchema.parse(forecastJson);

  return {
    current: { temp: currentData.main.temp, weather: currentData.weather },
    hourly: forecastData.list.map((v) => ({
      temp: v.main.temp,
      pop: v.pop,
      weather: v.weather,
    })),
  };
};

/**
 * 天候名
 */
export const WeatherName = {
  /** 雨 */
  Rain: "Rain",
  /** 雪 */
  Snow: "Snow",
  /** 霧など */
  Atmosphere: "Atmosphere",
  /** 晴れ */
  Clear: "Clear",
  /** 曇り */
  Clouds: "Clouds",
  /** 不明 */
  Unknown: "Unknown",
} as const;
export type WeatherName = (typeof WeatherName)[keyof typeof WeatherName];

/**
 * 天候 ID に対応した天候名のマップ
 */
const WeatherIdToName = [
  [/^[235]/, WeatherName.Rain],
  [/^6/, WeatherName.Snow],
  [/^7/, WeatherName.Atmosphere],
  [/^80[012]/, WeatherName.Clear],
  [/^80[34]/, WeatherName.Clouds],
] as const;

/**
 * 天候 ID に対応した天候名を返す
 *
 * ID 一覧: https://openweathermap.org/weather-conditions
 */
export const getWeatherNameById = (id: number): WeatherName => {
  for (const [pattern, name] of WeatherIdToName) {
    if (pattern.test(id.toString())) return name;
  }

  console.error(`[DEBUG] 未知の天気コード: ${id}`);

  return "Unknown";
};
