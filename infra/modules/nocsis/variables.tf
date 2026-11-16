variable "project_id" {
  description = "GCP / Firebase のプロジェクト ID"
  type        = string
}

variable "region" {
  description = "Cloud Run などのリージョン"
  type        = string
  default     = "asia-northeast1"
}

variable "auth_authorized_domains" {
  description = "Firebase Auth の承認済みドメイン"
  type        = list(string)
}

variable "auth_email_password_required" {
  description = "メールでのログインにパスワードを必須にするか (false ならメールリンクも使える)"
  type        = bool
}

variable "auth_google_client_id" {
  description = "Google ログインに使う OAuth クライアント ID"
  type        = string
}

variable "hosting_custom_domains" {
  description = "Firebase Hosting のデフォルトサイトに向けるカスタムドメイン"
  type        = list(string)
  default     = []
}

variable "hosting_app_id" {
  description = "デフォルトサイトに紐づける Firebase Web アプリの ID"
  type        = string
  default     = null
}
