export type Events = {
  /**
   * イベントがあるか
   * items が空の場合 true
   */
  isEmpty: boolean;

  /**
   * イベントリスト
   */
  items: EventData[];
};

export type EventData = {
  /**
   * イベント名
   */
  title: string;

  /**
   * 開始時刻
   * ISO 形式
   */
  startAt: string;

  /**
   * 終了時刻
   * ISO 形式
   */
  endAt: string;

  /**
   * 終日イベントかどうか
   */
  isAllDay: boolean;
};
