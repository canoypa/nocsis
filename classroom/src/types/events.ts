import { DateTime } from "luxon";

export type EventsData = {
  /** イベントがあるか */
  isEmpty: boolean;

  /** イベントリスト */
  items: EventData[];
};

export type EventData = {
  /** イベント名 */
  title: string;
  /** 全日イベントかどうか */
  isAllDay: boolean;

  /** 開始日時 */
  startAt: DateTime;
  /** 終了日時 */
  endAt: DateTime;
};
