import { HttpsError } from "firebase-functions/https";
import { DateTime } from "luxon";
import { getDayduty } from "~/core/dayduty/getDayduty.js";

type DayDuty = {
  /**
   * 出席番号
   */
  stuNo: number;
  
  /**
   * 名前
   */
  name: string;

  /**
   * @deprecated use `name`
   */
  firstName: string;
  
  /**
   * @deprecated use `name`
   */
  lastName: string;
};

type Args = {
  groupId: string;
  date: string;
};

const get = async (data: Args): Promise<DayDuty> => {
  const date = DateTime.fromISO(data.date, { zone: "asia/tokyo" });
  if (date === null) {
    throw new HttpsError("invalid-argument", "date is not ISO format");
  }

  const student = await getDayduty(data.groupId, date.startOf("day"));

  const response = {
    stuNo: student.stuNo,
    name: student.name,
    firstName: student.firstName,
    lastName: student.lastName,
  };

  return response;
};
export default get;
