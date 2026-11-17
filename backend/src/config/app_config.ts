/**
 * アプリケーション設定
 */
export const AppConfig = {
  /**
   * アプリケーションのデフォルトタイムゾーン
   */
  TIMEZONE: "Asia/Tokyo",

  /**
   * このアプリのリポジトリ。エラーのログに該当行へのリンクを付けるのに使う
   */
  REPOSITORY_URL: "https://github.com/canoypa/nocsis",

  /**
   * フロントエンドのソースマップを置くバケットの名前の末尾。`<プロジェクト ID>-` に続ける
   */
  SOURCE_MAP_BUCKET_SUFFIX: "frontend-source-maps",
} as const;
