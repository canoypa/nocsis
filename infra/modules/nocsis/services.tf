# アプリとデプロイに要る API だけを持つ。ここに無い API は止めない (member 単位と同じく、足すだけ)。
locals {
  services = toset(concat([
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouderrorreporting.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "containerregistry.googleapis.com",
    "deploymentmanager.googleapis.com",
    "eventarc.googleapis.com",
    "firebase.googleapis.com",
    "firebaseextensions.googleapis.com",
    "firebasehosting.googleapis.com",
    "firebaserules.googleapis.com",
    "firestore.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "identitytoolkit.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "runtimeconfig.googleapis.com",
    "secretmanager.googleapis.com",
    "source.googleapis.com",
    "securetoken.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "sts.googleapis.com",
  ], var.extra_services))
}

resource "google_project_service" "this" {
  for_each = local.services

  project = var.project_id
  service = each.value

  # Terraform から外しても API は止めない。止めると、その API のリソースが動かなくなる。
  disable_on_destroy         = false
  disable_dependent_services = false
}

# 止める API。一覧から外すと destroy で止まる。
resource "google_project_service" "retiring" {
  for_each = var.retiring_services

  project = var.project_id
  service = each.value

  disable_on_destroy = true
  # 依存しているものを一緒に止めない。依存関係は API から読めない分もあり (source を止めると
  # cloudfunctions も止めようとした)、一緒に止めると使う API まで止まりうる。依存があれば止めるのを断られる。
  disable_dependent_services = false

  lifecycle {
    precondition {
      condition     = !contains(local.services, each.value)
      error_message = "使う API (local.services / extra_services) は止められない。"
    }
  }
}

# Cloud Functions が依存していて止められなかった。
moved {
  from = google_project_service.retiring["source.googleapis.com"]
  to   = google_project_service.this["source.googleapis.com"]
}

# Data Access の監査ログ。サービスごとに、記録する種類を全部書く。
resource "google_project_iam_audit_config" "this" {
  for_each = var.audit_log_configs

  project = var.project_id
  service = each.key

  dynamic "audit_log_config" {
    for_each = toset(each.value)
    content {
      log_type = audit_log_config.value
    }
  }
}
