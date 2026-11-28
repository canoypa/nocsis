# 日直の確定と通知のジョブ。backend は Cloud Run の公開サービスなので、呼び手は backend が
# この SA の OIDC トークンで確かめる。SA 自身はプロジェクトの権限を持たない。
# account_id と audience は backend の AppConfig (JOB_SERVICE_ACCOUNT / JOB_TOKEN_AUDIENCE) と合わせる。
resource "google_service_account" "backend_jobs" {
  account_id   = "backend-jobs"
  display_name = "backend jobs"
  description  = "Cloud Scheduler が backend のジョブを呼ぶときの OIDC トークンにだけ使う。権限は持たない。"
}

# ジョブを作る tf-apply が、この SA をジョブに付けるのに要る。
resource "google_service_account_iam_member" "backend_jobs_tf_apply" {
  service_account_id = google_service_account.backend_jobs.name
  role               = "roles/iam.serviceAccountUser"
  member             = local.tf_apply_member
}

resource "google_cloud_scheduler_job" "dayduty_finalize" {
  name        = "dayduty-finalize"
  description = "昨日までの日直を確定する"
  region      = var.region
  schedule    = "5 0 * * *"
  time_zone   = "Asia/Tokyo"

  # Hosting の rewrite は Cloud Run への要求を 60 秒で切る。
  attempt_deadline = "60s"

  # 確定は日ごとにまだない日だけを書くので、呼び直しても二重に書かない。
  retry_config {
    retry_count          = 5
    min_backoff_duration = "60s"
    max_backoff_duration = "900s"
  }

  http_target {
    http_method = "POST"
    uri         = "${var.backend_url}/api/v1/jobs/dayduty-finalize"

    oidc_token {
      service_account_email = google_service_account.backend_jobs.email
      audience              = "nocsis-backend-jobs"
    }
  }

  depends_on = [
    google_project_service.this,
    google_project_iam_member.tf_apply,
    google_service_account_iam_member.backend_jobs_tf_apply,
  ]
}

resource "google_cloud_scheduler_job" "dayduty_notify" {
  name        = "dayduty-notify"
  description = "今日の日直を Slack で知らせる"
  region      = var.region
  schedule    = "0 7 * * *"
  time_zone   = "Asia/Tokyo"

  # Hosting の rewrite は Cloud Run への要求を 60 秒で切る。
  attempt_deadline = "60s"

  # 呼び直すと、送れたグループにもう一度送る。送れなかったグループはログに残す。
  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "${var.backend_url}/api/v1/jobs/dayduty-notify"

    oidc_token {
      service_account_email = google_service_account.backend_jobs.email
      audience              = "nocsis-backend-jobs"
    }
  }

  depends_on = [
    google_project_service.this,
    google_project_iam_member.tf_apply,
    google_service_account_iam_member.backend_jobs_tf_apply,
  ]
}

# 通知に使うグループの Slack のトークン。group_* の Secret は Terraform の外で作るので、
# Secret ごとではなく名前で絞って読ませる。
resource "google_project_iam_member" "backend_runtime_slack_tokens" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = google_service_account.this["backend-runtime"].member

  condition {
    title      = "group-slack-tokens"
    expression = <<-EOT
      resource.name.startsWith("projects/${data.google_project.this.number}/secrets/group_") &&
      resource.name.extract("/secrets/{name}/").endsWith("-slack_token")
    EOT
  }
}
