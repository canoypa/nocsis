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
  description = "Secret の名前 => 読める SA (backend-runtime / functions-runtime)"
  type        = map(list(string))
  default     = {}

  # 空にすると binding が全員を外す。
  validation {
    condition     = alltrue([for accessors in values(var.secrets) : length(accessors) > 0])
    error_message = "読める SA を 1 つ以上書く。"
  }

  # 既定の SA (compute / appspot) で動くものは無いので、読ませない。
  validation {
    condition = alltrue(flatten([
      for accessors in values(var.secrets) : [for a in accessors : contains(["backend-runtime", "functions-runtime"], a)]
    ]))
    error_message = "読める SA は backend-runtime か functions-runtime。既定の SA (compute / appspot) には読ませない。"
  }
}

variable "extra_services" {
  description = "その環境にだけ要る API"
  type        = list(string)
  default     = []
}

variable "retiring_services" {
  description = "止める API。取り込んでから一覧から外すと止まる"
  type        = list(string)
  default     = []
}

variable "audit_log_configs" {
  description = "Data Access の監査ログ (サービス => ADMIN_READ / DATA_READ / DATA_WRITE)"
  type        = map(list(string))
  default     = {}

  validation {
    condition = alltrue(flatten([
      for types in values(var.audit_log_configs) : concat(
        [length(types) > 0],
        [for t in types : contains(["ADMIN_READ", "DATA_READ", "DATA_WRITE"], t)],
      )
    ]))
    error_message = "記録する種類を ADMIN_READ / DATA_READ / DATA_WRITE から 1 つ以上書く。"
  }
}
