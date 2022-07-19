import { useCallback, useState } from "react";
import { useRecoilValueLoadable } from "recoil";
import { ClassesSelector } from "../atoms/classes";
import { getNewDate } from "../core/date";
import { ClassData } from "../types/classes";
import { useIntervalEffect } from "./date";

type UseClasses = () => {
  /** 授業中か */
  during: boolean;
  /** 現行の授業 */
  current: ClassData | null;
};

/** 進行中の授業があるか管理する hook */
export const useDuringClass: UseClasses = () => {
  const { state, contents: classes } = useRecoilValueLoadable(ClassesSelector);

  const [during, setDuring] = useState<boolean>(false);
  const [current, setCurrent] = useState<ClassData | null>(null);

  // 進行中の授業があるかチェック
  const checkCurrentClass = useCallback(() => {
    if (state !== "hasValue") {
      return;
    }

    if (!classes.isEmpty) {
      const date = getNewDate();

      // 進行中の授業を取得、なければ null
      const currentClass = classes.items.find(
        (v) =>
          0 <= date.diff(v.startAt).as("milliseconds") &&
          date.diff(v.endAt).as("milliseconds") <= 0
      );

      if (currentClass) {
        setCurrent(currentClass);
        setDuring(true);
      } else {
        setDuring(false);
      }
    }
  }, [classes]);

  useIntervalEffect(checkCurrentClass, "minute", [checkCurrentClass]);

  return {
    during,
    current,
  };
};
