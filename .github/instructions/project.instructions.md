---
applyTo: "**"
---

## プロジェクト概要

Nocsis (ノクシス) は、学校・クラス向けの情報管理サービスです。
授業やイベントの管理、表示、通知などを行います。

## 技術スタック

### 共通

- **CI/CD**: GitHub Actions
- **認証**: Firebase Authentication
- **データベース**: Cloud Firestore
- **ファイルストレージ**: Cloud Storage
- **機密情報管理**: Secret Manager

### Backend (Cloud Run)

- **デプロイ先**: Cloud Run
- **技術スタック**:
  - Node.js v22
  - TypeScript
  - Hono v4
  - OpenAPI v3
- **パッケージマネージャー**: pnpm
- **テストフレームワーク**: Vitest
- **リンター/フォーマッター**: Biome

### Functions (Cloud Functions)

- **デプロイ先**: Cloud Functions
- **技術スタック**:
  - Node.js v22
  - TypeScript
  - Firebase Functions v6
- **パッケージマネージャー**: pnpm
- **テストフレームワーク**: Vitest
- **リンター/フォーマッター**: Biome

### Frontend (Flutter)

- **デプロイ先**: Firebase Hosting
- **技術スタック**:
  - Flutter v3
  - Dart
  - Riverpod v2
  - go_router v15
- **パッケージマネージャー**: pub
- **テストフレームワーク**: Flutter Test
