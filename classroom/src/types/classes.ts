import { DateTime } from "luxon";

export type ClassesData = {
  /** 授業があるか */
  isEmpty: boolean;

  /** 授業リスト */
  items: ClassData[];
};

export type ClassData = {
  /** 授業名 */
  title: string;
  /** 何時間目か */
  period: number;

  /** 開始時間 */
  startAt: DateTime;
  /** 終了時間 */
  endAt: DateTime;
};
