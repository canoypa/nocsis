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

type Arg = {
  lat: string;
  lon: string;
};

/**
 * OpenWeatherMap API から天気情報を取得する
 */
export const fetchWeather = async ({ lat, lon }: Arg): Promise<WeatherData> => {
  if (!process.env.OPENWEATHERMAP_TOKEN) {
    throw new Error("Can not read OpenWeatherMap Environment Variables");
  }

  const baseParams = {
    appid: process.env.OPENWEATHERMAP_TOKEN,
    lat,
    lon,
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
