import { Fade } from "@mui/material";
import { FC } from "react";
import { useDuringClass } from "../hooks/class";
import { DuringClassScreen } from "./during_class_screen";
import { HomeScreen } from "./home_screen";

export const Main: FC = () => {
  const classState = useDuringClass();

  return (
    <>
      <Fade in={!classState.during} mountOnEnter unmountOnExit>
        {/* given ref */}
        <div>
          <HomeScreen />
        </div>
      </Fade>

      <Fade in={classState.during} mountOnEnter unmountOnExit>
        {/* given ref */}
        <div>
          {/* Fixme */}
          <DuringClassScreen classData={classState.current!} />
        </div>
      </Fade>
    </>
  );
};
