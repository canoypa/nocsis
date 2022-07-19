import { Box, Paper, Typography } from "@mui/material";
import { FC } from "react";
import { ClassData } from "../types/classes";
import { ListTile } from "./listtile";

type Props = {
  items: ClassData[];
};
export const ClassesList: FC<Props> = ({ items }) => {
  return (
    <Paper sx={{ height: "100%" }}>
      <Box display="flex" flexDirection="column" rowGap={3} p={4}>
        <Typography fontSize="3rem" color="text.secondary">
          今日の授業
        </Typography>

        {items.map((v) => (
          <ListTile
            key={v.period}
            title={v.title}
            subtitle={
              <Box display="flex" columnGap={2} alignItems="baseline">
                <Typography
                  key="period"
                  fontSize="2.4rem"
                  color="textSecondary"
                >
                  {v.period} 時限目
                </Typography>
                <Typography key="time" fontSize="2.4rem" color="textSecondary">
                  <span>{v.startAt.toFormat("H:mm")}</span>
                  <span> ~ </span>
                  <span>{v.endAt.toFormat("H:mm")}</span>
                </Typography>
              </Box>
            }
          />
        ))}
      </Box>
    </Paper>
  );
};
