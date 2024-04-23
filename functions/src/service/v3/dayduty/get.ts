import { HttpsError } from "firebase-functions/v2/https";
import { DateTime } from "luxon";
import { getDayduty } from "../../../core/dayduty/getDayduty.js";

type DayDuty = {
  stuNo: number;
  firstName: string;
  lastName: string;
};

type Args = {
  date: string;
};

const get = async (data: Args): Promise<DayDuty> => {
  const date = DateTime.fromISO(data.date, { zone: "asia/tokyo" });
  if (date === null) {
    throw new HttpsError("invalid-argument", "date is not ISO format");
  }

  const student = await getDayduty(date.startOf("day"));

  const response = {
    stuNo: student.stuNo,
    firstName: student.firstName,
    lastName: student.lastName,
  };

  return response;
};
export default get;
