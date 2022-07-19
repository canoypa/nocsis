export type Classes = {
  /**
   * 授業があるか
   * items が空の場合 true
   */
  isEmpty: boolean;

  /**
   * 授業リスト
   */
  items: ClassData[];
};

export type ClassData = {
  /**
   * 授業名
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
   * 何時間目か
   */
  period: number;
};
