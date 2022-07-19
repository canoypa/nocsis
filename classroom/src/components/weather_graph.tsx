import { FC } from "react";
import { useMeasure } from "react-use";
import { selector, useRecoilValue_TRANSITION_SUPPORT_UNSTABLE } from "recoil";
import { WeatherState } from "../atoms/weather";

type WeatherGraphState = {
  tempPoints: { x: number; y: number }[];
  popPoints: { x: number; y: number }[];
};
const WeatherGraphState = selector<WeatherGraphState>({
  key: "weatherGraph",
  get: async ({ get }) => {
    const { hourly } = get(WeatherState);

    const maxTemp = Math.max(...hourly.temp);
    const minTemp = Math.min(...hourly.temp);

    // TODO: もうちょっとうまいこと対応して
    const tempRange = Math.max(1, maxTemp - minTemp);

    const tempPoints = hourly.temp.map((v, i) => {
      const ratio = (v - minTemp) / tempRange;
      const x = i / (hourly.temp.length - 1);
      const y = (1 - ratio) / 2;
      return { x, y };
    });

    const popPoints = hourly.pop.map((v, i) => {
      const x = i / (hourly.pop.length - 1);
      const y = 0.5 + (1 - v) / 2;
      return { x, y };
    });

    return { tempPoints, popPoints };
  },
  cachePolicy_UNSTABLE: {
    eviction: "most-recent",
  },
});

export const WeatherGraph: FC = () => {
  const weather = useRecoilValue_TRANSITION_SUPPORT_UNSTABLE(WeatherGraphState);

  const [ref, { width, height }] = useMeasure<HTMLDivElement>();

  return (
    <div ref={ref} style={{ height: "100%" }}>
      {weather && (
        <svg
          width={width}
          height={height}
          style={{
            overflow: "visible",
          }}
        >
          <path
            d={[
              ...weather.tempPoints
                .concat(weather.popPoints.slice().reverse())
                .map((v, i) => {
                  return `${i === 0 ? "M" : "L"} ${width * v.x} ${
                    height * v.y
                  }`;
                }),
              "Z",
            ].join("")}
            fill="rgba(255, 213, 79, 0.2)"
            style={{
              transition: "d 300ms cubic-bezier(0.0,0.0,0.2,1)",
            }}
          />
          <path
            d={[
              ...weather.tempPoints.map((v, i) => {
                return `${i === 0 ? "M" : "L"} ${width * v.x} ${height * v.y}`;
              }),
            ].join("")}
            fill="none"
            stroke="#FFD54F"
            strokeWidth={4}
            style={{
              transition: "d 300ms cubic-bezier(0.0,0.0,0.2,1)",
            }}
          />

          <path
            d={[
              ...weather.popPoints.map((v, i) => {
                return `${i === 0 ? "M" : "L"} ${width * v.x} ${height * v.y}`;
              }),
              `L${width} ${height}`,
              `L0 ${height}`,
              "Z",
            ].join("")}
            fill="rgba(100, 181, 246, 0.2)"
            style={{
              transition: "d 300ms cubic-bezier(0.0,0.0,0.2,1)",
            }}
          />
          <path
            d={[
              ...weather.popPoints.map((v, i) => {
                return `${i === 0 ? "M" : "L"} ${width * v.x} ${height * v.y}`;
              }),
            ].join(" ")}
            fill="none"
            stroke="#64B5F6"
            strokeWidth={4}
            style={{
              transition: "d 300ms cubic-bezier(0.0,0.0,0.2,1)",
            }}
          />
        </svg>
      )}
    </div>
  );
};
