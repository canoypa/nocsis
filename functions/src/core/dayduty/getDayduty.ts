import type { DateTime } from "luxon";
import { getDaydutyStuNo } from "../../services/classmates/getDaydutyStuNo.js";
import { getStudentByStuNo } from "../../services/classmates/getStudentByStuNo.js";
import type { Student } from "../../types/classmates.js";

/**
 * 入力された日時の日直を取得する
 */
export const getDayduty = async (
  groupId: string,
  date: DateTime,
): Promise<Student> => {
  const stuNo = await getDaydutyStuNo(groupId, date);
  const [dayduty] = await getStudentByStuNo(groupId, stuNo);

  return dayduty;
};
