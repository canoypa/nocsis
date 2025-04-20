import { HttpsError } from "firebase-functions/https";
import { DateTime } from "luxon";
import { getDayduty } from "~/core/dayduty/getDayduty.js";
import type { Student } from "~/types/classmates.js";

type DayDuty = Pick<Student, "stuNo" | "name" | "firstName" | "lastName">;

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
