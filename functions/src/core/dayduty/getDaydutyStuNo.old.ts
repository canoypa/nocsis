import { DateTime } from "luxon";
import { getStudentCount } from "../../services/classmates/getStudentCount.js";

/**
 * 入力された日時の日直の出席番号を取得する
 * @deprecated 複数クラスで使用できるようにする(#314)対応に伴ってgroupカラムが追加され、将来的に適切な値を返すことができなくなるため
 */
export const getDaydutyStuNo = async (date: DateTime): Promise<number> => {
  // 日直制度の開始日
  const startDateEnv = process.env.DAYDUTY_START_DATE;
  if (!startDateEnv) {
    throw new Error("Can not read DAYDUTY_START_DATE");
  }

  const startDate = DateTime.fromISO(startDateEnv, { zone: "Asia/Tokyo" });

  const elapseDays = Math.floor(
    date.setZone("asia/tokyo").diff(startDate).as("days"),
  );

  const classmatesCount = await getStudentCount();

  const stuNo = (elapseDays % classmatesCount) + 1;

  return stuNo;
};
