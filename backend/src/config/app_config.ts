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
   * Cloud Scheduler がジョブを呼ぶときに使う SA の account_id。infra の Terraform と合わせる
   */
  JOB_SERVICE_ACCOUNT: "backend-jobs",

  /**
   * ジョブを呼ぶ OIDC トークンの audience。infra の Terraform と合わせる
   */
  JOB_TOKEN_AUDIENCE: "nocsis-backend-jobs",

  /**
   * フロントエンドのソースマップを置くバケットの名前の末尾。`<プロジェクト ID>-` に続ける
   */
  SOURCE_MAP_BUCKET_SUFFIX: "frontend-source-maps",

  /**
   * Google ログインに使う OAuth クライアントの ID。プロジェクト ID ごと
   */
  GOOGLE_OAUTH_CLIENT_IDS: {
    "class-clock-40088":
      "219141289630-1duqb26tbk7dte61804hjqg64qmhfsc2.apps.googleusercontent.com",
    "nocsis-development":
      "862064818225-50oucenghkua7qb7hqlpm6vfqp20b6h7.apps.googleusercontent.com",
  } as Record<string, string | undefined>,
} as const;
