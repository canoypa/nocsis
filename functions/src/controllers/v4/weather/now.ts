import { getFirestore } from "firebase-admin/firestore";
import { type CallableRequest, HttpsError } from "firebase-functions/https";
import { firebaseApp } from "~/client/firebaseApp.js";
import { getWeatherNameById } from "../../../core/weather/getWeatherNameById.js";
import { fetchWeather } from "../../../services/weather/fetch_weather.js";
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

type Request = CallableRequest<{
  groupId: string;
}>;

const now = async (request: Request): Promise<WeathersResponse> => {
  const firestore = getFirestore(firebaseApp);

  const userJoinedGroupSnapshot = await firestore
    .collection("user_joined_groups")
    .where("user_id", "==", request.auth?.uid)
    .where("group_id", "==", request.data.groupId)
    .get();
  if (userJoinedGroupSnapshot.empty) {
    throw new HttpsError(
      "permission-denied",
      "You are not a member of this group",
    );
  }

  const groupSnapshot = await firestore
    .collection("groups")
    .doc(request.data.groupId)
    .get();
  const group = groupSnapshot.data();
  if (!group) {
    throw new HttpsError("invalid-argument", "Group not found");
  }

  const lat = group.weather_point.lat;
  const lon = group.weather_point.lon;
  if (!lat || !lon) {
    throw new HttpsError("internal", "Internal error");
  }
  const openWeatherData = await fetchWeather({ lat, lon });

  // 現在の天気と気温
  const current = {
    name: getWeatherNameById(openWeatherData.hourly[0].weather[0].id),
    temp: openWeatherData.current.temp,
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
