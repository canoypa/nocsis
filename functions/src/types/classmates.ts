export type Classmate = {
  /**
   * グループ ID
   */
  group_id: string;

  /**
   * Slack の ID
   */
  slackUserId: string;
};

export type Student = Classmate & {
  role: "student";

  /**
   * 出席番号
   */
  stuNo: number;

  /**
   * 名前
   */
  name: string;

  /**
   * 名前
   * @deprecated use `name`
   */
  firstName?: string;

  /**
   * 名字
   * @deprecated use `name`
   */
  lastName?: string;
};

export type Teacher = Classmate & {
  role: "teacher";
};
