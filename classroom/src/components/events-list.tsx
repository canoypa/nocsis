import { Box, Paper, Typography } from "@mui/material";
import { FC } from "react";
import { EventData } from "../types/events";
import { ListTile } from "./listtile";

type Props = {
  items: EventData[];
};
export const EventsList: FC<Props> = ({ items }) => {
  return (
    <Paper sx={{ height: "100%" }}>
      <Box display="flex" flexDirection="column" rowGap={3} p={4}>
        <Typography fontSize="3rem" color="text.secondary">
          今後のイベント
        </Typography>

        {items.map((v) => {
          // 日付
          const dateElm = (
            <Typography key="date" fontSize="2.4rem" color="textSecondary">
              {v.startAt.toFormat("M月d日")}
            </Typography>
          );

          return (
            <ListTile
              key={`${v.title}-${v.startAt.toISO()}`}
              title={v.title}
              subtitle={
                <Box display="flex" columnGap={2} alignItems="baseline">
                  {dateElm}
                </Box>
              }
            />
          );
        })}
      </Box>
    </Paper>
  );
};
