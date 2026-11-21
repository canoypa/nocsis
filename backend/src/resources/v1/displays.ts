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

const displayName = z.string().trim().min(1).max(50);

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
    name: displayName.meta({ description: "名前" }),
  })
  .meta({
    $id: "DisplayCreateJson",
    description: "教室ディスプレイの登録に使う JSON データ",
  });

export const displayPatchJsonSchema = z
  .object({
    name: displayName.meta({ description: "名前" }),
  })
  .meta({
    $id: "DisplayPatchJson",
    description: "教室ディスプレイの更新に使う JSON データ",
  });
