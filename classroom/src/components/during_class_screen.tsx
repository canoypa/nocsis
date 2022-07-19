import { Box } from "@mui/material";
import { FC } from "react";
import { ClassData } from "../types/classes";
import { ClassInfo } from "./during_class_info";
import { ClassProgress } from "./during_class_progress";

type Props = {
  classData: ClassData;
};
export const DuringClassScreen: FC<Props> = ({ classData }) => {
  return (
    <Box
      display="flex"
      alignItems="center"
      justifyContent="center"
      height="100vh"
    >
      <ClassProgress classData={classData} />
      <ClassInfo classData={classData} />
    </Box>
  );
};
