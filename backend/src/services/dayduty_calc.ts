import { DateTime } from "luxon";

/** 先生の操作。その人の `turn` 回目の番を使ったことにする */
export type DaydutyOp = {
  date: string;
  kind: "skip";
  member: string;
  turn: number;
};

/** 人の決まり。当てはまる日は、その人を選ばない。曜日は ISO (月曜 1 〜 日曜 7) */
export type DaydutyRule =
  | { member: string; weekdays: number[] }
  | { member: string; from: string; to: string };

export type DaydutyDay = {
  date: string;
  members: string[];
  /** この日に使った番の数が変わった人と、変わった後の値。まだ数がなかった人は最初の日に入る */
  turns: Record<string, number>;
};

const MEMBERS_PER_DAY = 1;

const isBlocked = (
  rules: readonly DaydutyRule[],
  member: string,
  date: DateTime,
) =>
  rules.some((rule) => {
    if (rule.member !== member) return false;
    if ("weekdays" in rule) return rule.weekdays.includes(date.weekday);
    const day = date.toISODate() as string;
    return rule.from <= day && day <= rule.to;
  });

/**
 * 名簿にいて使った番の数がまだない人は、いる人の最大の数から始める
 */
export const fillTurns = (
  order: readonly string[],
  turns: Readonly<Record<string, number>>,
): Record<string, number> => {
  const known = order.filter((m) => m in turns).map((m) => turns[m]);
  const start = known.length ? Math.max(...known) : 0;
  return Object.fromEntries(order.map((m) => [m, turns[m] ?? start]));
};

/**
 * from から to までの日直を決める
 *
 * @param order 決めた順番に並んだ生徒 ID
 * @param turns from の前日を終えた時点の、各人の使った番の数
 */
export const computeDayduty = (input: {
  order: readonly string[];
  turns: Readonly<Record<string, number>>;
  from: string;
  to: string;
  ops: readonly DaydutyOp[];
  rules: readonly DaydutyRule[];
}): { days: DaydutyDay[]; turns: Record<string, number> } => {
  const { order, ops, rules } = input;
  const turns = fillTurns(order, input.turns);
  const position = new Map(order.map((m, i) => [m, i]));
  const raise = (member: string, value: number) => {
    if (value > turns[member]) turns[member] = value;
  };

  const days: DaydutyDay[] = [];
  let previous: Record<string, number | undefined> = { ...input.turns };
  const end = DateTime.fromISO(input.to, { zone: "utc" });
  for (
    let date = DateTime.fromISO(input.from, { zone: "utc" });
    date <= end;
    date = date.plus({ days: 1 })
  ) {
    const day = date.toISODate() as string;

    for (const op of ops) {
      if (op.kind === "skip" && op.date === day && position.has(op.member))
        raise(op.member, op.turn + 1);
    }

    const members = order
      .filter((m) => !isBlocked(rules, m, date))
      .sort(
        (a, b) =>
          turns[a] - turns[b] ||
          (position.get(a) as number) - (position.get(b) as number),
      )
      .slice(0, MEMBERS_PER_DAY);

    const last = members.at(-1);
    if (last !== undefined) {
      const lastTurn = turns[last];
      const lastPosition = position.get(last) as number;
      for (const m of members) turns[m] += 1;
      for (const m of order) {
        if (!isBlocked(rules, m, date)) continue;
        const passedTurn =
          lastTurn + ((position.get(m) as number) < lastPosition ? 1 : 0);
        raise(m, passedTurn);
      }
    }

    const changed = Object.fromEntries(
      order.filter((m) => turns[m] !== previous[m]).map((m) => [m, turns[m]]),
    );
    previous = { ...turns };
    days.push({ date: day, members, turns: changed });
  }

  return { days, turns };
};
