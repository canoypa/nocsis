import { Box } from "@mui/material";
import { FC, Suspense } from "react";
import { HomeDate } from "./date";
import { Dayduty } from "./dayduty";
import { WeatherInfo } from "./weather_info";

export const HomeScreenLeft: FC = () => {
  return (
    <Box height="100%" display="flex" flexDirection="column">
      <Suspense fallback={null}>
        <WeatherInfo />
      </Suspense>

      <Box flex={1} />

      <Box>
        <Dayduty />
        <Box height={24} />
        <HomeDate />
      </Box>
    </Box>
  );
};
