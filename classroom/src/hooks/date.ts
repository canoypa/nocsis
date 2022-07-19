import { DateTime, DateTimeUnit } from "luxon";
import { DependencyList, useEffect, useRef } from "react";
import { getNewDate } from "../core/date";

type IntervalConfig = number | DateTimeUnit | ((date: DateTime) => number);

const getNextTiming = (interval: IntervalConfig) => {
  const now = getNewDate();

  if (typeof interval === "number") {
    return interval;
  }

  if (typeof interval === "string") {
    // 超冗長ミュータブルミラクルクソコード
    // なんか .startOf(now, {unit: "seconds"}) とかあるのでは？？？

    let compDate = now.plus({ [interval]: 1 }).startOf(interval);

    return compDate.diff(now).as("milliseconds");
  }

  if (typeof interval === "function") {
    return interval(now);
  }
};

/**
 * 定期実行される Effect
 *
 * interval
 * number: ms指定 setInterval と同等、普通に定期
 * string: IntervalValues指定 時刻に基づいて実行
 * (date: Date) => number: 実行時Dateを元にms指定 10分ごととか、毎時30分とか
 */
export const useIntervalEffect = (
  effect: () => void,
  interval: IntervalConfig,
  deps: DependencyList = []
) => {
  const timeoutId = useRef<number>(0);

  useEffect(() => {
    const setTimeout = (handler: () => void) => {
      timeoutId.current = window.setTimeout(handler, getNextTiming(interval));
    };

    const update = () => {
      effect();
      setTimeout(update);
    };

    // 初回実行
    update();

    return () => {
      window.clearTimeout(timeoutId.current);
    };
  }, [interval, ...deps]);
};
