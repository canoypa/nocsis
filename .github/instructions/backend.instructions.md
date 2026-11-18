---
applyTo: "backend/**"
paths:
  - "backend/**"
---

# backend（Hono / Cloud Run）

## OpenAPI が frontend との契約

各コントローラは `hono-openapi` の `describeRoute` と zod スキーマ（`src/resources/v1/`）で定義され、そこから `frontend/swagger/api.json` を生成する。frontend の API クライアントは**コミット済みの** api.json から生成されるため、api.json が古いと backend と食い違ったクライアントができる。

スキーマやルートを変えたら `pnpm run generate-openapi` を実行し、`frontend/swagger/api.json` を同じコミットに含める。CI の `lint-backend` が再生成して `git diff --exit-code` で落とす。

## 認証の後に、認可のミドルウェアを置く

`middlewares/authenticate.ts` は Firebase ID トークンを検証して `currentUserId` を context に置くところで終わる。認可はその後ろに置く `authorize(permission, groupOf("..."))`（`middlewares/authorize.ts`）が `role_bindings` を見て決める。コントローラで参加を確かめ直さない。

権限が1つも無い相手には、リソースがあっても 404 を返す（403 との違いで存在が分かるため）。binding が残ったままグループが消えていることがあるので、グループの存在はコントローラで確かめる。

## テストは `.spec.ts`

対象は `src/**/*.spec.ts`。functions は `.test.ts` なので、綴りを引きずらない。同じ Firestore を共有するため `fileParallelism: false` が要る。

## レスポンスの項目は2段階で外す

frontend の生成クライアントは required の項目をそろっている前提で読む。項目を外したり任意にしたりすると、古い版を開いたままの画面が、データを取り直したときに壊れる。

1. 項目を任意にして `deprecated` を付け、frontend が読まないようにする。backend はまだ返す
2. 1 が本番に出て1日ほど空けてから、backend から項目を外す

リクエストに必須の項目を足すときは逆で、先に任意で受け付ける版を出してから必須にする。古い画面は新しい項目を送らない。

CI の `api-compat` が `api.json` の互換性を壊す変更で落ちる。1 のように意図した変更は、PR に `skip-api-compat` ラベルを付けて再実行すれば通る。ラベルは PR に付いている限り効くので、意図した変更の PR にだけ付ける。
