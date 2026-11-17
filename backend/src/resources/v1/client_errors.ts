import { z } from "zod";

export const clientErrorSchema = z
  .object({
    message: z.string().max(2000).meta({ description: "エラーのメッセージ" }),
    stack: z
      .string()
      .max(16000)
      .meta({ description: "ブラウザが返したままのスタックトレース" }),
    commit: z
      .string()
      .regex(/^[0-9a-f]{40}$/)
      .meta({ description: "フロントエンドをビルドした commit" }),
    compiler: z
      .enum(["dart2wasm", "dart2js"])
      .meta({ description: "動いていたコンパイル結果" }),
    path: z
      .string()
      .max(200)
      .meta({ description: "エラーが起きた画面のパス (クエリは含めない)" }),
  })
  .meta({
    $id: "ClientError",
    description: "フロントエンドで起きたエラー",
  });
