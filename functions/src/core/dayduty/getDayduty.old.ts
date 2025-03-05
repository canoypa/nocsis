import type { DateTime } from "luxon";
import { getStudentByStuNo } from "../../services/classmates/getStudentByStuNo.old.js";
import type { Student } from "../../types/classmates.js";
import { getDaydutyStuNo } from "./getDaydutyStuNo.old.js";

/**
 * 入力された日時の日直を取得する
 * @deprecated 複数クラスで使用できるようにする(#314)対応に伴ってgroupカラムが追加され、将来的に適切な値を返すことができなくなるため
 */
export const getDayduty = async (date: DateTime): Promise<Student> => {
  const stuNo = await getDaydutyStuNo(date);
  const [dayduty] = await getStudentByStuNo(stuNo);

  return dayduty;
};
