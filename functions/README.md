# Nocsis Functions

Nocsis のバックエンド関数です
各種データの受け渡しや他サービスの API 呼び出しを行います

## スクリーンショット

![](/docs/images/slack_event.png)
![](/docs/images/slack_dayduty.png)

## 機能一覧

- 指定したアドレス以外でのアカウント作成のブロック
- その日の日直の通知
- イベントがある日にはその内容を通知
- 特定の日の授業を取得
- 特定の日のイベントを取得
- 月ごとに一年分のイベント一覧を取得
- 現在の室温と天気予報を取得

## 使用している技術

### 言語

- TypeScript

### 外部サービス

- Google Calendar
- Slack
- OpenWeatherMap
- SwitchBot

### ランタイム

- Cloud Functions for Firebase
