import { getFunctions, httpsCallable } from "firebase/functions";
import { firebaseApp } from "../core/firebase_app";
import { WeatherData } from "../types/weather";

export const getWeather = async (): Promise<WeatherData> => {
  const functions = getFunctions(firebaseApp, "asia-northeast1");
  const getWeatherFn = httpsCallable(functions, "v2-weather-now");

  const { data } = await getWeatherFn();

  return data as WeatherData;
};
