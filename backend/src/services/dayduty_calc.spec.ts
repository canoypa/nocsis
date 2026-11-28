import { describe, expect, it } from "vitest";
import { computeDayduty, type DaydutyRule } from "./dayduty_calc.js";

const order = ["A", "B", "C", "D"];
const start = { A: 0, B: 0, C: 0, D: 0 };

const membersOf = (result: ReturnType<typeof computeDayduty>) =>
  result.days.map((day) => day.members.join(""));

describe("computeDayduty", () => {
  it("決めた順番に1人ずつ回ること", () => {
    const result = computeDayduty({
      order,
      turns: start,
      from: "2026-11-30",
      to: "2026-12-05",
      ops: [],
      rules: [],
    });

    expect(membersOf(result)).toEqual(["A", "B", "C", "D", "A", "B"]);
  });

  it("使った番の数が少ない人から選ぶこと", () => {
    const result = computeDayduty({
      order,
      turns: { A: 1, B: 1, C: 0, D: 0 },
      from: "2026-11-30",
      to: "2026-12-02",
      ops: [],
      rules: [],
    });

    expect(membersOf(result)).toEqual(["C", "D", "A"]);
  });

  it("飛ばした人の番が、その周だけなくなること", () => {
    // 12/1 の B を飛ばす
    const result = computeDayduty({
      order,
      turns: start,
      from: "2026-11-30",
      to: "2026-12-04",
      ops: [{ date: "2026-12-01", kind: "skip", member: "B", turn: 0 }],
      rules: [],
    });

    expect(membersOf(result)).toEqual(["A", "C", "D", "A", "B"]);
  });

  it("飛ばす番がもう済んでいたら、何も変わらないこと", () => {
    const result = computeDayduty({
      order,
      turns: start,
      from: "2026-11-30",
      to: "2026-12-04",
      ops: [{ date: "2026-12-02", kind: "skip", member: "A", turn: 0 }],
      rules: [],
    });

    expect(membersOf(result)).toEqual(["A", "B", "C", "D", "A"]);
  });

  it("名簿にいない人を飛ばしても、何も変わらないこと", () => {
    const result = computeDayduty({
      order,
      turns: start,
      from: "2026-11-30",
      to: "2026-12-01",
      ops: [{ date: "2026-11-30", kind: "skip", member: "Z", turn: 0 }],
      rules: [],
    });

    expect(membersOf(result)).toEqual(["A", "B"]);
  });

  it("選ばれない曜日に回ってきた番は、なくなること", () => {
    // 2026-11-25 は水曜
    const rules: DaydutyRule[] = [{ member: "B", weekdays: [3] }];
    const result = computeDayduty({
      order,
      turns: start,
      from: "2026-11-24",
      to: "2026-11-28",
      ops: [],
      rules,
    });

    expect(membersOf(result)).toEqual(["A", "C", "D", "A", "B"]);
  });

  it("選ばれない期間の間は回らず、明けたら順番どおりに戻ること", () => {
    const rules: DaydutyRule[] = [
      { member: "B", from: "2026-12-02", to: "2026-12-07" },
    ];
    const result = computeDayduty({
      order,
      turns: start,
      from: "2026-12-01",
      to: "2026-12-11",
      ops: [],
      rules,
    });

    expect(membersOf(result)).toEqual([
      "A",
      "C",
      "D",
      "A",
      "C",
      "D",
      "A",
      "B",
      "C",
      "D",
      "A",
    ]);
  });

  it("選ばれない日でも、番が回ってこなければ何も変わらないこと", () => {
    const rules: DaydutyRule[] = [
      { member: "D", from: "2026-11-30", to: "2026-11-30" },
    ];
    const result = computeDayduty({
      order,
      turns: start,
      from: "2026-11-30",
      to: "2026-12-03",
      ops: [],
      rules,
    });

    expect(membersOf(result)).toEqual(["A", "B", "C", "D"]);
  });

  it("全員が選ばれない日は、日直がいないこと", () => {
    const rules: DaydutyRule[] = order.map((member) => ({
      member,
      weekdays: [1],
    }));
    // 2026-11-30 は月曜
    const result = computeDayduty({
      order,
      turns: start,
      from: "2026-11-29",
      to: "2026-12-01",
      ops: [],
      rules,
    });

    expect(membersOf(result)).toEqual(["A", "", "B"]);
  });

  it("名簿に入った人は、次の周の自分の位置から入ること", () => {
    // A と B が済んだ周の途中で E が入る
    const result = computeDayduty({
      order: [...order, "E"],
      turns: { A: 1, B: 1, C: 0, D: 0 },
      from: "2026-12-01",
      to: "2026-12-08",
      ops: [],
      rules: [],
    });

    expect(membersOf(result)).toEqual(["C", "D", "A", "B", "C", "D", "E", "A"]);
  });

  it("名簿から抜けた人は選ばないこと", () => {
    const result = computeDayduty({
      order: ["A", "C", "D"],
      turns: { A: 1, B: 0, C: 0, D: 0 },
      from: "2026-12-01",
      to: "2026-12-03",
      ops: [],
      rules: [],
    });

    expect(membersOf(result)).toEqual(["C", "D", "A"]);
  });

  it("その日に使った番の数が変わった人と、変わった後の値を返すこと", () => {
    const result = computeDayduty({
      order: [...order, "E"],
      turns: { A: 5, B: 4, C: 4, D: 4 },
      from: "2026-12-01",
      to: "2026-12-02",
      ops: [{ date: "2026-12-02", kind: "skip", member: "C", turn: 4 }],
      rules: [],
    });

    expect(result.days).toEqual([
      { date: "2026-12-01", members: ["B"], turns: { B: 5, E: 5 } },
      { date: "2026-12-02", members: ["D"], turns: { C: 5, D: 5 } },
    ]);
    expect(result.turns).toEqual({ A: 5, B: 5, C: 5, D: 5, E: 5 });
  });

  it("名簿が空なら、どの日も日直がいないこと", () => {
    const result = computeDayduty({
      order: [],
      turns: {},
      from: "2026-12-01",
      to: "2026-12-02",
      ops: [],
      rules: [],
    });

    expect(membersOf(result)).toEqual(["", ""]);
  });
});
