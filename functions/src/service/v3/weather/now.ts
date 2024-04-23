import { fetchWeather } from "../../../core/weather/fetchWeather.js";
import {
  type SwitchbotStatusBody,
  fetchSwitchbotStatus,
} from "../../../core/weather/fetch_switchbot_status.js";
import { getWeatherNameById } from "../../../core/weather/getWeatherNameById.js";
import type { WeatherName } from "../../../types/weather.js";

export type WeathersResponse = {
  /**
   * 現在の天気
   */
  current: {
    /** 気温 */
    temp: number;
    /** 天候名 */
    name: WeatherName;
  };

  hourly: {
    temp: number[];
    pop: number[];
  };

  threeHour: [WeatherName, WeatherName, WeatherName];
};

const calcSwitchbotTempAvg = (data: SwitchbotStatusBody[]): number => {
  const result =
    data.map((v) => v.temperature).reduce((a, b) => a + b, 0) / data.length;
  return result;
};

const now = async (): Promise<WeathersResponse> => {
  const [openWeatherData, switchbotData] = await Promise.all([
    fetchWeather(),
    fetchSwitchbotStatus(),
  ]);

  // 現在の天気と気温
  const current = {
    name: getWeatherNameById(openWeatherData.hourly[0].weather[0].id),
    temp: Math.round(calcSwitchbotTempAvg(switchbotData)),
  };

  // 3 時間先までの天気
  const threeHour = openWeatherData.hourly
    .slice(1, 4)
    .map((v) => getWeatherNameById(v.weather[0].id)) as [
    WeatherName,
    WeatherName,
    WeatherName,
  ];

  // 8 時間先までの気温と降水確率
  const hourly = openWeatherData.hourly.slice(0, 9).reduce(
    (p: { temp: number[]; pop: number[] }, v) => {
      p.temp.push(Math.round(v.temp));
      p.pop.push(v.pop);

      return p;
    },
    { temp: [], pop: [] },
  );

  return {
    current,
    hourly,
    threeHour,
  };
};
export default now;
