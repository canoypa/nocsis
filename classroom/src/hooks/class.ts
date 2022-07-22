import { Interval } from "luxon";
import { useCallback, useState } from "react";
import { useRecoilValue } from "recoil";
import { ClassesSelector } from "../atoms/classes";
import { getNewDate } from "../core/date";
import { ClassData } from "../types/classes";
import { useIntervalEffect } from "./date";

export type DuringClassState =
  | { during: true; classData: ClassData }
  | { during: false; classData: null };

/** 進行中の授業を確認する hook */
export const useDuringClass = (): DuringClassState => {
  const classes = useRecoilValue(ClassesSelector);

  const [state, setState] = useState<DuringClassState>({
    during: false,
    classData: null,
  });

  // 進行中の授業があるかチェック
  const checkCurrentClass = useCallback(() => {
    if (!classes.isEmpty) {
      const date = getNewDate();

      const currentClass = classes.items.find((v) =>
        // date が授業時間内かのチェック
        // endAt は排他的なので -1 しとく
        Interval.fromDateTimes(v.startAt, v.endAt.minus(1)).contains(date)
      );

      if (currentClass) {
        setState({ during: true, classData: currentClass });
      } else {
        setState({ during: false, classData: null });
      }
    }
  }, [classes]);

  useIntervalEffect(checkCurrentClass, "minute", [checkCurrentClass]);

  return state;
};
