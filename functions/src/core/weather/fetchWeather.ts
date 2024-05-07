import axios from "axios";

export type WeatherData = {
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

export type OWMCurrentWeatherData = {
  weather: { id: number; main: string }[];
  main: { temp: number };
};

export type OWMFiveDayWeatherForecastData = {
  list: {
    dt: number;
    main: { temp: number };
    pop: number;
    weather: { id: number; main: string }[];
  }[];
};

const CurrentWeatherEndpoint =
  "https://api.openweathermap.org/data/2.5/weather";
const FiveDayWeatherForecastEndpoint =
  "https://api.openweathermap.org/data/2.5/forecast";

/**
 * OpenWeatherMap API から天気情報を取得する
 */
export const fetchWeather = async (): Promise<WeatherData> => {
  if (
    !process.env.OPENWEATHERMAP_TOKEN ||
    !process.env.WEATHER_POINT_LAT ||
    !process.env.WEATHER_POINT_LON
  ) {
    throw new Error("Can not read OpenWeatherMap Environment Variables");
  }

  const baseParams = {
    appid: process.env.OPENWEATHERMAP_TOKEN,
    lat: process.env.WEATHER_POINT_LAT,
    lon: process.env.WEATHER_POINT_LON,
    units: "metric",
  };

  const forecastParams = {
    ...baseParams,
    cnt: 8,
  };

  const [{ data: currentData }, { data: forecastData }] = await Promise.all([
    axios.get<OWMCurrentWeatherData>(CurrentWeatherEndpoint, {
      params: baseParams,
    }),
    axios.get<OWMFiveDayWeatherForecastData>(FiveDayWeatherForecastEndpoint, {
      params: forecastParams,
    }),
  ]);

  const data: WeatherData = {
    current: {
      temp: currentData.main.temp,
      weather: currentData.weather,
    },
    hourly: forecastData.list.map((v) => ({
      temp: v.main.temp,
      pop: v.pop,
      weather: v.weather,
    })),
  };

  return data;
};
