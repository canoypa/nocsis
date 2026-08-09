---
applyTo: "functions/**"
paths:
  - "functions/**"
---

# functions（Cloud Functions）

**新しい機能をここに足さない。** 認可をアプリ側へ移して Cloud Functions 自体を無くす方向にあるので、追加は backend に置く。以下は既存を保守するときの前提。

## 定期実行のために関数を増やさない

スケジューラは毎分実行の `scheduled.main` 1本だけ。実行時刻の判定は `src/core/crontab.ts` がアプリ内で行い、該当するサービスを動的 import する。定期処理を足す先は `src/controllers/scheduled/main.ts` で、新しい `onSchedule` を定義しない。

## service account はグローバルに指定する

`src/config/functions.ts` の `setGlobalOptions` が全関数に `functions-runtime@<project>.iam.gserviceaccount.com` を設定している。個別の関数定義で指定する形にすると、後から追加した関数が指定漏れでデフォルトの compute SA（`roles/editor`）に落ちる。

このアドレスを `functions-runtime@` で止める省略形は使わない。デプロイ時には補完されるが、宣言したシークレットへのアクセス付与では補完されず、生の値が `setIamPolicy` に渡って `Invalid service account` で落ちる。

## テストは `.test.ts` で、project が2つある

対象は `src/**/*.test.ts`。backend は `.spec.ts` なので、綴りを引きずらない。vitest project は2つあり、`src/{controllers,services}` 以外は `--project default` で Firestore 無しに回る。エミュレータを使う側は各テスト後に Firestore を全消しするので、テスト間でデータを持ち越せない。
