export const WeatherNames = {
  Clear: "Clear",
  Clouds: "Clouds",
  Rain: "Rain",
  Snow: "Snow",
  Atmosphere: "Atmosphere",
  Unknown: "Unknown",
};
export type WeatherNames = typeof WeatherNames[keyof typeof WeatherNames];

export type WeatherData = {
  /** 現在の天気 */
  current: {
    name: WeatherNames;
    temp: number;
  };

  /** 1時間毎 8時間先までの天気 */
  hourly: HourWeatherData;

  /** 3時間の天気 */
  threeHour: WeatherNames[];
};

export type HourWeatherData = {
  temp: number[];
  pop: number[];
};
