/**
 * 認可の主体。
 *
 * 認証の境界を通ってくるものだけが principal になる。定期実行は境界の内側で
 * 走るので主体を持たない（`system` のような主体を作らない）。
 * ical 出力（#94）を入れるときに `{ kind: "token"; id: string }` が増える。
 */
export type Principal = { kind: "user"; uid: string };

export const user = (uid: string): Principal => ({ kind: "user", uid });

/** role_bindings.subject に保存する表現 */
export const subject = (principal: Principal): string =>
  `${principal.kind}:${principal.uid}`;
