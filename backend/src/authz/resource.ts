/** ロールを付与できるリソースの型 */
export type ResourceType = "group";

/** binding の付け先 */
export type ResourceRef = { type: "group"; id: string };

export const group = (id: string): ResourceRef => ({ type: "group", id });

/** role_bindings.resource に保存する表現 */
export const serialize = (ref: ResourceRef): string => `${ref.type}:${ref.id}`;

/**
 * 祖先チェーン。自分自身を含み、祖先に対する binding も判定に効く。
 *
 * 親子はドメインのデータから引く。認可専用の親フィールドを Firestore に作らない。
 * 管理画面（#90）を作るときに ROOT が末尾に足される。
 *
 * 網羅していない型が増えると「返り値が undefined になり得る」でコンパイルエラーになる。
 */
export const ancestors = (ref: ResourceRef): ResourceRef[] => {
  switch (ref.type) {
    case "group":
      return [ref];
  }
};
