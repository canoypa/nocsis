import { Box, Typography } from "@mui/material";
import { FC, ReactNode } from "react";

type Props = {
  title: ReactNode;
  subtitle?: ReactNode;
};
export const ListTile: FC<Props> = ({ subtitle, title }) => {
  return (
    <Box>
      <Typography fontSize="4rem">{title}</Typography>
      {subtitle}
    </Box>
  );
};
