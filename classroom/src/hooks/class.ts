import { useCallback, useState } from "react";
import { useRecoilValue } from "recoil";
import { ClassesSelector } from "../atoms/classes";
import { getNewDate } from "../core/date";
import { ClassData } from "../types/classes";
import { useIntervalEffect } from "./date";

export type DuringClassState =
  | { during: true; classData: ClassData }
  | { during: false; classData: null };

/** 進行中の授業があるか管理する hook */
export const useDuringClass = (): DuringClassState => {
  const classes = useRecoilValue(ClassesSelector);

  const [_state, setState] = useState<DuringClassState>({
    during: false,
    classData: null,
  });

  // 進行中の授業があるかチェック
  const checkCurrentClass = useCallback(() => {
    if (!classes.isEmpty) {
      const date = getNewDate();

      // 進行中の授業を取得、なければ null
      const currentClass = classes.items.find(
        (v) =>
          0 <= date.diff(v.startAt).as("milliseconds") &&
          date.diff(v.endAt).as("milliseconds") <= 0
      );

      if (currentClass) {
        setState({ during: true, classData: currentClass });
      } else {
        setState({ during: false, classData: null });
      }
    }
  }, [classes]);

  useIntervalEffect(checkCurrentClass, "minute", [checkCurrentClass]);

  return _state;
};
