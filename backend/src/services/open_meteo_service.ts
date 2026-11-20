import { z } from "zod";

export type WeatherData = {
  current: { temp: number; weatherCode: number };
  /** 3時間ごと、24時間先までの予報 */
  hourly: { temp: number; pop: number; weatherCode: number }[];
};

interface FetchWeatherParams {
  lat: number;
  lon: number;
}

const ForecastResponseSchema = z.object({
  current: z.object({
    temperature_2m: z.number(),
    weather_code: z.number(),
  }),
  hourly: z.object({
    temperature_2m: z.array(z.number()),
    // 降水確率だけ欠けた時刻があっても、予報全体は落とさない
    precipitation_probability: z.array(z.number().nullable()),
    weather_code: z.array(z.number()),
  }),
});

const FORECAST_ENDPOINT = "https://api.open-meteo.com/v1/forecast";

const FORECAST_STEP_HOURS = 3;
const FORECAST_SLOTS = 8;

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
 * Open-Meteo の Forecast API から天気情報を取得する
 */
const fetchWeatherFromApi = async ({
  lat,
  lon,
}: FetchWeatherParams): Promise<WeatherData> => {
  const url = new URL(FORECAST_ENDPOINT);
  url.searchParams.set("latitude", lat.toString());
  url.searchParams.set("longitude", lon.toString());
  url.searchParams.set("current", "temperature_2m,weather_code");
  url.searchParams.set(
    "hourly",
    "temperature_2m,precipitation_probability,weather_code",
  );
  // hourly は今の時刻 (正時) から始まる
  url.searchParams.set(
    "forecast_hours",
    (FORECAST_STEP_HOURS * FORECAST_SLOTS + 1).toString(),
  );
  url.searchParams.set("timeformat", "unixtime");

  const res = await fetch(url, {
    signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
  });
  if (!res.ok) {
    throw new Error("天気データの取得に失敗しました");
  }

  const data = ForecastResponseSchema.parse(await res.json());

  const hourly = Array.from({ length: FORECAST_SLOTS }, (_, i) => {
    const index = FORECAST_STEP_HOURS * (i + 1);
    const temp = data.hourly.temperature_2m[index];
    const weatherCode = data.hourly.weather_code[index];
    if (temp === undefined || weatherCode === undefined) {
      throw new Error("天気データの予報が足りません");
    }
    const pop = data.hourly.precipitation_probability[index] ?? 0;
    return { temp, pop: pop / 100, weatherCode };
  });

  return {
    current: {
      temp: data.current.temperature_2m,
      weatherCode: data.current.weather_code,
    },
    hourly,
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
 * WMO の天気コードに対応した天候名のマップ
 */
const WeatherCodeToName: Record<number, WeatherName> = {
  0: WeatherName.Clear,
  // 晴れ時々曇りまでは晴れとして見せる
  1: WeatherName.Clear,
  2: WeatherName.Clear,
  3: WeatherName.Clouds,
  45: WeatherName.Atmosphere,
  48: WeatherName.Atmosphere,
  51: WeatherName.Rain,
  53: WeatherName.Rain,
  55: WeatherName.Rain,
  56: WeatherName.Rain,
  57: WeatherName.Rain,
  61: WeatherName.Rain,
  63: WeatherName.Rain,
  65: WeatherName.Rain,
  66: WeatherName.Rain,
  67: WeatherName.Rain,
  71: WeatherName.Snow,
  73: WeatherName.Snow,
  75: WeatherName.Snow,
  77: WeatherName.Snow,
  80: WeatherName.Rain,
  81: WeatherName.Rain,
  82: WeatherName.Rain,
  85: WeatherName.Snow,
  86: WeatherName.Snow,
  95: WeatherName.Rain,
  96: WeatherName.Rain,
  99: WeatherName.Rain,
};

/**
 * WMO の天気コードに対応した天候名を返す
 *
 * コード一覧: https://open-meteo.com/en/docs (WMO Weather interpretation codes)
 */
export const getWeatherNameByCode = (code: number): WeatherName => {
  const name = WeatherCodeToName[code];
  if (name) return name;

  console.error(`[DEBUG] 未知の天気コード: ${code}`);

  return WeatherName.Unknown;
};
