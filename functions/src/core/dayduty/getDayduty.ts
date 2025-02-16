import type { DateTime } from "luxon";
import { getStudentByStuNo } from "../../services/classmates/getStudentByStuNo.js";
import type { Student } from "../../types/classmates.js";
import { getDaydutyStuNo } from "./getDaydutyStuNo.js";

/**
 * 入力された日時の日直を取得する
 */
export const getDayduty = async (date: DateTime): Promise<Student> => {
  const stuNo = await getDaydutyStuNo(date);
  const [dayduty] = await getStudentByStuNo(stuNo);

  return dayduty;
};
