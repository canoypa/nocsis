import { Fade } from "@mui/material";
import { FC, memo } from "react";
import { DuringClassState, useDuringClass } from "../hooks/class";
import { DuringClassScreen } from "./during_class_screen";
import { HomeScreen } from "./home_screen";

// 授業が始まるときのみ更新するため、メモ化する
// メモ化はパフォーマンス目的で使用すべき？だが、取り敢えず useDuringClass を綺麗にするのが目的なのでこれで
const memorizedDuringClassScreen: FC<{ classState: DuringClassState }> = ({
  classState,
}) => {
  // FIXME: non-null assertion
  return <DuringClassScreen classData={classState.classData!} />;
};
const MemorizedDuringClassScreen = memo(
  memorizedDuringClassScreen,
  (prev, next) =>
    !(prev.classState.during === false && next.classState.during === true)
);

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
          <MemorizedDuringClassScreen classState={classState} />
        </div>
      </Fade>
    </>
  );
};
