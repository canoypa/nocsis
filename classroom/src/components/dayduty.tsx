import { PersonPinOutlined } from "@mui/icons-material";
import { Box, Typography } from "@mui/material";
import { FC } from "react";
import { useRecoilValue } from "recoil";
import { DaydutyState } from "../atoms/dayduty";

export const Dayduty: FC = () => {
  const dayduty = useRecoilValue(DaydutyState);

  return (
    <Box display="flex" columnGap={2} alignItems="center">
      <PersonPinOutlined sx={{ fontSize: "4rem" }} />
      <Typography fontSize="4rem" lineHeight={1}>
        {dayduty.lastName}
        {dayduty.firstName}
      </Typography>
    </Box>
  );
};
