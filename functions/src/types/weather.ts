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
export type WeatherName = typeof WeatherName[keyof typeof WeatherName];
