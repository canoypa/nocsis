import { WeatherName } from "../../types/weather.js";

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
  for (const [pattern, weather] of WeatherIdToName) {
    if (pattern.test(id.toString())) {
      return weather;
    }
  }

  // 不明な天候 ID の場合、エラーログを吐いて Unknown を返す
  console.error(`Error: Unknown weather code: ${id}`);
  return WeatherName.Unknown;
};
