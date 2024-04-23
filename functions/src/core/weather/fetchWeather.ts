import axios from "axios";

export type OpenWeatherMapOneCallResponse = {
  current: {
    temp: number;
    weather: { id: number; main: string }[];
  };
  hourly: {
    temp: number;
    pop: number;
    weather: { id: number; main: string }[];
  }[];
};

// FIXME: no any
/**
 * OpenWeatherMap API から天気情報を取得する
 */
export const fetchWeather =
  async (): Promise<OpenWeatherMapOneCallResponse> => {
    const url = "https://api.openweathermap.org/data/2.5/onecall";

    if (
      !process.env.OPENWEATHERMAP_TOKEN ||
      !process.env.WEATHER_POINT_LAT ||
      !process.env.WEATHER_POINT_LON
    ) {
      throw new Error("Can not read OpenWeatherMap Environment Variables");
    }

    const params = {
      appid: process.env.OPENWEATHERMAP_TOKEN,
      lat: process.env.WEATHER_POINT_LAT,
      lon: process.env.WEATHER_POINT_LON,
      units: "metric",
      exclude: "current,minutely,daily,alerts",
    };

    const { data } = await axios.get<OpenWeatherMapOneCallResponse>(url, {
      params,
    });

    return data;
  };
