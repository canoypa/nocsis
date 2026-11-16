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

variable "extra_service_accounts" {
  description = "その環境にだけある SA (account_id => 表示名と説明)"
  type = map(object({
    display_name = string
    description  = optional(string)
  }))
  default = {}
}

variable "wlif_deploy_environments" {
  description = "wlif-deploy を引ける GitHub の environment"
  type        = list(string)
}

variable "claude_readonly_email" {
  description = "このクラウド環境の閲覧用 SA。Staging のプロジェクトにある"
  type        = string
  default     = "claude-readonly@nocsis-development.iam.gserviceaccount.com"
}

variable "secrets" {
  description = "Secret の名前 => 読める SA (secrets.tf の secret_accessor_members のキー)"
  type        = map(list(string))
  default     = {}

  validation {
    condition = alltrue([
      for accessors in values(var.secrets) : length(accessors) > 0
    ])
    # 空にすると binding が全員を外す。
    error_message = "読める SA を 1 つ以上書く。"
  }
}
