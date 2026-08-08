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
