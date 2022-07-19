import { Box, useTheme } from "@mui/material";
import { FC, useState } from "react";
import { useRafLoop } from "react-use";
import { getNewDate } from "../core/date";
import { ClassData } from "../types/classes";

type Props = {
  classData: ClassData;
};
export const ClassProgress: FC<Props> = ({ classData }) => {
  const theme = useTheme();

  const [progress, setProgress] = useState(0);

  // progress を計算する
  useRafLoop(() => {
    const update = () => {
      // startTime からの経過時間を比較し進度を計算
      const nextProgress =
        Math.ceil(getNewDate().diff(classData.startAt).as("milliseconds")) /
        Math.ceil(classData.endAt.diff(classData.startAt).as("milliseconds"));

      // 進度が 1 を超えるまで繰り返し更新
      // 小数点以下 4 位まで (nn.nn%まで)
      if (nextProgress <= 1) {
        setProgress(Math.floor(nextProgress * 1e4) / 1e4);
      }
    };
    update();
  }, true);

  // 画面比率
  const ratio = window.innerHeight / window.innerWidth;

  // 48 基準で描画
  const svgSizeBase = 48;
  /** 角丸の半径 */
  const curveR = 2;

  /** svg のサイズ */
  const svgSize = { x: svgSizeBase, y: svgSizeBase * ratio };
  /** 線のサイズ */
  const size = { x: svgSize.x - 2, y: svgSize.y - 2 };

  /** 外周の長さ */
  const perimeter =
    (svgSize.x - curveR) * 2 +
    (svgSize.y - curveR) * 2 +
    (2 * Math.PI - 8) * curveR;

  return (
    <Box position="absolute" width="100vw" height="100vh">
      <svg viewBox={`0 0 ${svgSize.x} ${svgSize.y}`}>
        <path
          d={`
          M${svgSize.x / 2} 1
          l${size.x / 2 - curveR} 0
          a2 2 0 0 1 2 2
          l0 ${size.y - curveR * 2}
          a2 2 0 0 1-2 2
          l-${size.x - curveR * 2} 0
          a2 2 0 0 1-2-2
          l0-${size.y - curveR * 2}
          a2 2 0 0 12-2
          l${size.x / 2 - curveR} 0
          `}
          fill="none"
          stroke={theme.palette.surfaceVariant.main}
        />
        <path
          d={`
          M${svgSize.x / 2} 1
          l${size.x / 2 - curveR} 0
          a2 2 0 0 1 2 2
          l0 ${size.y - curveR * 2}
          a2 2 0 0 1-2 2
          l-${size.x - curveR * 2} 0
          a2 2 0 0 1-2-2
          l0-${size.y - curveR * 2}
          a2 2 0 0 12-2
          l${size.x / 2 - curveR} 0
          `}
          fill="none"
          stroke={theme.palette.primary.main}
          strokeDasharray={perimeter}
          strokeDashoffset={perimeter * (1 - progress)}
        />
      </svg>
    </Box>
  );
};
