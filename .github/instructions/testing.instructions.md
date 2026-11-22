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

- 画面: 表示される文言と、ボタンなどの操作
- API: レスポンスのステータスと本文

内部の関数の呼び出し回数や、provider の組み方は確かめない。実装を組み替えただけで落ちるテストになる。

ただし、外部への呼び出し自体が結果のとき（Google に問い合わせたか、通知を送ったか）は、回数を確かめてよい。

## モックは外部サービスにだけ使う

次はエミュレータで動かし、モックにしない。

- backend: Firestore と Auth
- functions: `src/{controllers,services}` のテストの Firestore

モックにするのは次だけ。

- 外部サービス（Google Calendar、天気 API など）。backend は msw を使う
- frontend の API クライアントと Firebase Auth（firebase_auth_mocks）

エミュレータで起こせない失敗（Auth の更新エラーなど）を試すときだけ、内部を spy してよい。内部のサービスを `vi.mock` している既存のテストは、真似しない。

## バグを見つけたら、先に再現するテストを書く

直す前に、そのバグで落ちるテストを足す。落ちるのを見てから直す。

## テストの中で分岐しない

`if` の中に expect を置くと、その条件を通らなかったときに何も確かめずに通る。条件ごとにテストを分ける。
