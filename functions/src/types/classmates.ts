export type Classmate = {
  /**
   * 名前
   */
  name: string;
  
  /**
   * 名前
   * @deprecated use `name`
   */
  firstName: string;

  /**
   * 名字
   * @deprecated use `name`
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
