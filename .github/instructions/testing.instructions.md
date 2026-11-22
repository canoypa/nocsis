---
applyTo: "backend/src/**/*.spec.ts,backend/tests/**,functions/src/**/*.test.ts,functions/tests/**,frontend/test/**,frontend/integration_test/**"
paths:
  - "backend/src/**/*.spec.ts"
  - "backend/tests/**"
  - "functions/src/**/*.test.ts"
  - "functions/tests/**"
  - "frontend/test/**"
  - "frontend/integration_test/**"
---

# テスト

## 外から見える結果で確かめる

画面なら表示される文言と操作、API ならレスポンスのステータスと本文で確かめる。内部の関数が何回呼ばれたか、provider がどう組まれているかは見ない。実装を組み替えただけでテストが落ちると、落ちたことが壊れたことの合図にならない。外部への呼び出しそのものが結果のとき（Google に問い合わせたか、通知を送ったか）は、回数を見てよい。

## 偽物は外部との境目にだけ置く

backend は Firestore と Auth を、functions は `src/{controllers,services}` のテストで Firestore をエミュレータで本物として動かす。偽物にするのは、Google Calendar や天気 API のような外部サービスへの呼び出し（backend は msw）と、frontend から見た API クライアントと Firebase Auth（firebase_auth_mocks）だけ。

エミュレータでは起こせない失敗（Auth の更新エラーなど）を起こすときだけ、内部を spy してよい。既存のテストには内部のサービスを `vi.mock` しているものが残っているが、真似しない。

## バグを見つけたら、先に再現するテストを書く

直す前に、そのバグで落ちるテストを足す。落ちるのを見てから直す。

## テストの中で分岐しない

`if` で expect を飛ばすと、その経路を通ったときに何も確かめずに通る。条件ごとにテストを分ける。backend と functions は biome の `useExpect`・`noConditionalExpect`・`noFocusedTests`・`noSkippedTests` で検査している。
