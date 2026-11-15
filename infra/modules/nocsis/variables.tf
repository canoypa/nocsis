variable "project_id" {
  description = "GCP / Firebase のプロジェクト ID"
  type        = string
}

variable "region" {
  description = "Cloud Run などのリージョン"
  type        = string
  default     = "asia-northeast1"
}
