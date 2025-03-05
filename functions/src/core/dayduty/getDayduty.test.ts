import { DateTime } from "luxon";
import { describe, expect, it, vi } from "vitest";
import * as getStudentByStuNo from "~/services/classmates/getStudentByStuNo.js";
import type { Student } from "~/types/classmates.js";
import * as getDaydutyStuNo from "../../services/classmates/getDaydutyStuNo.js";
import { getDayduty } from "./getDayduty.js";

describe("getDayduty", () => {
  const data: Student = {
    stuNo: 1,
    firstName: "Foo",
    lastName: "Bar",
    slackUserId: "foobar",
  };
  it("戻り値が適切であること", async () => {
    const mockedGetDaydutyStuNo = vi
      .spyOn(getDaydutyStuNo, "getDaydutyStuNo")
      .mockResolvedValue(1);
    const mockedGetStudentByStuNo = vi
      .spyOn(getStudentByStuNo, "getStudentByStuNo")
      .mockResolvedValue([data]);

    await expect(
      getDayduty("group_1", DateTime.local(2025, 3, 1)),
    ).to.resolves.toEqual(data);
    expect(mockedGetDaydutyStuNo).toHaveBeenCalledWith(
      "group_1",
      DateTime.local(2025, 3, 1),
    );
    expect(mockedGetStudentByStuNo).toHaveBeenCalledWith("group_1", 1);
  });
});
