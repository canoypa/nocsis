import { NavigateNext } from "@mui/icons-material";
import { Breadcrumbs, Stack } from "@mui/material";
import { FC } from "react";
import { useRecoilValue_TRANSITION_SUPPORT_UNSTABLE } from "recoil";
import { WeatherState } from "../atoms/weather";
import { WeatherIcon } from "./weather_icons";

export const WeatherInfo: FC = () => {
  const weather = useRecoilValue_TRANSITION_SUPPORT_UNSTABLE(WeatherState);

  return (
    <Stack spacing={4}>
      <Stack direction="row" spacing={2} alignItems="center">
        <WeatherIcon name={weather.current.name} sx={{ fontSize: "8rem" }} />
        <Stack direction="row">
          <span style={{ fontSize: "8rem", lineHeight: "8rem" }}>
            {weather.current.temp}
          </span>
          <span style={{ fontSize: "4rem" }}>℃</span>
        </Stack>
      </Stack>

      <Breadcrumbs
        separator={<NavigateNext sx={{ fontSize: "64px" }} />}
        sx={{
          ".MuiBreadcrumbs-separator": { margin: 0 },
        }}
      >
        {weather.threeHour.map((v, i) => (
          <WeatherIcon key={i} name={v} sx={{ fontSize: "72px" }} />
        ))}
      </Breadcrumbs>
    </Stack>
  );
};
