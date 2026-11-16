---
applyTo: "backend/**"
paths:
  - "backend/**"
---

# backend（Hono / Cloud Run）

## OpenAPI が frontend との契約

各コントローラは `hono-openapi` の `describeRoute` と zod スキーマ（`src/resources/v1/`）で定義され、そこから `frontend/swagger/api.json` を生成する。frontend の API クライアントは**コミット済みの** api.json から生成されるため、api.json が古いと backend と食い違ったクライアントができる。

スキーマやルートを変えたら `pnpm run generate-openapi` を実行し、`frontend/swagger/api.json` を同じコミットに含める。CI の `lint-backend` が再生成して `git diff --exit-code` で落とす。

## ミドルウェアがやるのは認証まで

`middlewares/authenticate.ts` は Firebase ID トークンを検証して `currentUserId` を context に置くところで終わる。認可はここに無いので、「そのグループに参加しているか」は各コントローラが自分で確かめる。

## テストは `.spec.ts`

対象は `src/**/*.spec.ts`。functions は `.test.ts` なので、綴りを引きずらない。同じ Firestore を共有するため `fileParallelism: false` が要る。

## レスポンスの項目は2段階で外す

frontend の生成クライアントは required の項目をそろっている前提で読む。項目を外したり任意にしたりすると、古い版を開いたままの画面が、データを取り直したときに壊れる。

1. 項目を任意にして `deprecated` を付け、frontend が読まないようにする。backend はまだ返す
2. 1 が本番に出て1日ほど空けてから、backend から項目を外す

CI の `api-compat` が `api.json` の互換性を壊す変更で落ちる。1 のように意図した変更は、PR に `breaking_api` ラベルを付けて再実行すれば通る。教室画面だけは操作されないので、新しい版を見つけて自分でリロードする。
