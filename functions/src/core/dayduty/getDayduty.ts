import { DateTime } from "luxon";
import { Student } from "../../types/classmates";
import { getStudentByStuNo } from "../classmates/getStudentByStuNo";
import { getDaydutyStuNo } from "./getDaydutyStuNo";

/**
 * 入力された日時の日直を取得する
 */
export const getDayduty = async (date: DateTime): Promise<Student> => {
  const stuNo = await getDaydutyStuNo(date);
  const [dayduty] = await getStudentByStuNo(stuNo);

  return dayduty;
};
