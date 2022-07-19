import { Box } from "@mui/material";
import { FC, Suspense } from "react";
import { HomeScreenLeft } from "../components/home_screen_left";
import { HomeScreenRight } from "../components/home_screen_right";
import { WeatherGraph } from "../components/weather_graph";

export const HomeScreen: FC = () => {
  return (
    <Box height="100vh" display="grid" gridTemplateRows="1fr 40vh">
      <Box gridArea="2/2/-1/-1">
        <Suspense fallback={null}>
          <WeatherGraph />
        </Suspense>
      </Box>

      <Box
        gridArea="1/1/-1/-1"
        p={6}
        display="flex"
        columnGap={6}
        overflow="hidden"
      >
        <Box flex={1}>
          <HomeScreenLeft />
        </Box>

        <Box flex={1}>
          <Suspense fallback={null}>
            <HomeScreenRight />
          </Suspense>
        </Box>
      </Box>
    </Box>
  );
};
