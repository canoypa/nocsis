import { keyframes, styled, Typography } from "@mui/material";
import { NextPage } from "next";
import { useRecoilValue } from "recoil";
import { MinuteState } from "../atoms/date";

const FlashAnimation = keyframes({
  "50%": { opacity: 0.38 },
});

const Flash = styled("span")({
  animation: `${FlashAnimation} 2s steps(1) infinite`,
});

export const HomeDate: NextPage = () => {
  const date = useRecoilValue(MinuteState);

  return (
    <div>
      <Typography fontSize="14rem" lineHeight={1}>
        <span>{date.toFormat("H")}</span>
        <Flash>:</Flash>
        <span>{date.toFormat("mm")}</span>
      </Typography>
    </div>
  );
};
