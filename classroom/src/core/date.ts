import { DateObjectUnits, DateTime } from "luxon";

// 現在時刻をモックされたものにするかどうか
const __IsDebug__: boolean = false;

// モックする時間
const __MockTime__: DateObjectUnits = {};

const getMockedDateTime = () => {
  const mockedDate = DateTime.now()
    .startOf("day")
    .set(__MockTime__)
    .plus(globalThis.performance.now());

  return mockedDate;
};

export const getNewDate = (): DateTime => {
  return __IsDebug__ ? getMockedDateTime() : DateTime.now();
};
