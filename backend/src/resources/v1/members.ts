import { z } from "zod";

const graphemes = new Intl.Segmenter();

// max() は UTF-16 で数えるので、絵文字や濁点を合成した文字が2文字以上になる
const withinMemberNameLength = (name: string) =>
  [...graphemes.segment(name)].length <= 50;

const memberName = z
  .string()
  .trim()
  .min(1)
  .refine(withinMemberNameLength, "名前は50文字まで");

/** 一度に追加できる人数。1クラスの人数を十分に超える数 */
export const MEMBER_CREATE_LIMIT = 100;

export const memberSchema = z
  .object({
    id: z.string().meta({ description: "ID" }),
    number: z.int().min(1).meta({ description: "出席番号。1から並び順に振る" }),
    name: z.string().meta({ description: "名前" }),
  })
  .meta({
    $id: "Member",
    description: "グループの生徒。アカウントとは別に持つ名簿の1行",
  });

export const membersSchema = z
  .object({
    items: z.array(memberSchema).meta({ description: "出席番号の順" }),
  })
  .meta({
    $id: "Members",
    description: "グループの生徒の一覧",
  });

export const membersCreateJsonSchema = z
  .object({
    names: z
      .array(memberName)
      .min(1)
      .max(MEMBER_CREATE_LIMIT)
      .meta({ description: "名前。50文字まで。この順で末尾に加える" }),
  })
  .meta({
    $id: "MembersCreateJson",
    description: "生徒の追加に使う JSON データ",
  });

export const memberPatchJsonSchema = z
  .object({
    name: memberName.meta({ description: "名前。50文字まで" }),
  })
  .meta({
    $id: "MemberPatchJson",
    description: "生徒の更新に使う JSON データ",
  });

const memberIds = z
  .array(z.string())
  .min(1)
  .refine((ids) => new Set(ids).size === ids.length, "ID が重なっている");

export const membersOrderJsonSchema = z
  .object({
    ids: memberIds.meta({
      description: "グループの生徒全員の ID。この順に出席番号を振り直す",
    }),
  })
  .meta({
    $id: "MembersOrderJson",
    description: "生徒の並べ替えに使う JSON データ",
  });

export const membersDeleteJsonSchema = z
  .object({
    ids: memberIds.meta({ description: "削除する生徒の ID" }),
  })
  .meta({
    $id: "MembersDeleteJson",
    description: "生徒の削除に使う JSON データ",
  });
