---
applyTo: "**"
---

# ディレクトリ構成

```
nocsis/
├── scripts/                    # 開発用スクリプト
├── backend/                    # Hono ベースの REST API サーバー
│   ├── scripts/                # 開発用スクリプト
│   ├── src/
│   │   ├── clients/            # 外部サービスクライアント
│   │   ├── config/              # アプリケーション設定
│   │   ├── controllers/        # コントローラー
│   │   ├── middlewares/        # ミドルウェア
│   │   ├── resources/          # OpenAPI リソース定義
│   │   └── services/           # サービス層
│   ├── tests/                  # テスト用コード
│   │   └── helpers/            # テストヘルパー
│   └── Dockerfile               # Cloud Run デプロイ用
├── functions/                  # Cloud Functions サービス
│   ├── src/
│   │   ├── client/             # 外部サービスクライアント
│   │   ├── config/              # アプリケーション設定
│   │   ├── controllers/        # コントローラー
│   │   ├── core/               # コアビジネスロジック
│   │   ├── services/           # サービス層
│   │   └── types/              # 型定義
│   └── tests/                  # テスト用設定・ヘルパー
└── frontend/                   # Flutter ベースの Web フロントエンド
    ├── assets/                 # 静的リソース
    │   ├── fonts/              # フォントリソース
    │   └── images/             # 画像リソース
    ├── lib/
    │   ├── components/         # 再利用可能な UI コンポーネント
    │   ├── core/               # コア機能（API クライアント、定数等）
    │   ├── extensions/         # 拡張メソッド
    │   ├── generated/          # 自動生成ファイル（build_runner）
    │   ├── pages/              # ページレベルウィジェット
    │   ├── providers/          # Riverpod プロバイダー
    │   ├── routes/             # go_router ルーティング設定
    │   ├── screens/            # 画面レベルウィジェット
    │   ├── templates/          # レイアウトテンプレート
    │   └── themes/             # アプリケーションテーマ
    ├── swagger/
    │   └── api.json            # backend の OpenAPI 仕様
    ├── test/                   # テストファイル
    └── web/                    # Web 固有ファイル
```
