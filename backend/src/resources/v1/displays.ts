import { z } from "zod";

export const displayPairingSchema = z
  .object({
    code: z
      .string()
      .regex(/^\d{6}$/)
      .meta({ description: "管理者が入力する6桁のコード" }),
    expires_at: z.iso
      .datetime()
      .meta({ description: "コードが使えなくなる日時" }),
  })
  .meta({
    $id: "DisplayPairing",
    description: "教室ディスプレイを登録するためのコード",
  });

const graphemes = new Intl.Segmenter();

// max() は UTF-16 で数えるので、絵文字や濁点を合成した文字が見た目より長くなる
const withinDisplayNameLength = (name: string) =>
  [...graphemes.segment(name)].length <= 50;

const displayName = z
  .string()
  .trim()
  .min(1)
  .refine(withinDisplayNameLength, "名前は50文字まで");

export const displaySchema = z
  .object({
    id: z.string().meta({ description: "ID" }),
    name: z.string().meta({ description: "名前" }),
    created_at: z.iso.datetime().meta({ description: "登録した日時" }),
    removed_at: z.iso.datetime().nullable().meta({
      description:
        "使われなくなり、登録が解除された日時。解除されていなければ null",
    }),
  })
  .meta({
    $id: "Display",
    description: "教室ディスプレイ",
  });

export const displaysSchema = z
  .object({
    items: z.array(displaySchema).meta({ description: "新しく登録した順" }),
  })
  .meta({
    $id: "Displays",
    description: "グループの教室ディスプレイ",
  });

export const displayCreateJsonSchema = z
  .object({
    code: displayPairingSchema.shape.code,
    name: z
      .string()
      .trim()
      .refine(withinDisplayNameLength, "名前は50文字まで")
      .optional()
      .meta({
        description:
          "名前。見た目で50文字まで。省くか空にすると、グループで使われていない「ディスプレイ N」を付ける",
      }),
  })
  .meta({
    $id: "DisplayCreateJson",
    description: "教室ディスプレイの登録に使う JSON データ",
  });

export const displayPatchJsonSchema = z
  .object({
    name: displayName.meta({ description: "名前。見た目で50文字まで" }),
  })
  .meta({
    $id: "DisplayPatchJson",
    description: "教室ディスプレイの更新に使う JSON データ",
  });
