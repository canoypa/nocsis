import { Box, Typography } from "@mui/material";
import { FC, useMemo } from "react";
import { useRecoilValue } from "recoil";
import { MinuteState } from "../atoms/date";
import { ClassData } from "../types/classes";

type Props = {
  classData: ClassData;
};
export const ClassInfo: FC<Props> = ({ classData }) => {
  const date = useRecoilValue(MinuteState);

  const remain = useMemo(() => {
    const now = date.startOf("minute");
    const newRemain = Math.ceil(classData.endAt.diff(now).as("minutes"));
    return Math.max(newRemain, 0);
  }, [classData.endAt, date]);

  return (
    <Box display="flex" flexDirection="column" alignItems="center">
      <Typography fontSize="3rem" color="textSecondary">
        {classData.period} 時限目
      </Typography>
      <Typography fontSize="3rem">{classData.title}</Typography>
      <Typography fontSize="16rem" lineHeight={1.2}>
        {remain}分
      </Typography>
    </Box>
  );
};
