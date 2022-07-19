export type Classmate = {
  /**
   * 名前
   */
  firstName: string;

  /**
   * 名字
   */
  lastName: string;

  /**
   * Slack の ID
   */
  slackUserId: string;
};

export type Student = Classmate & {
  /**
   * 出席番号
   */
  stuNo: number;
};

export type Teacher = Classmate;
