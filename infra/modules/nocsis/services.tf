# アプリとデプロイに要る API だけを持つ。ここに無い API は止めない (member 単位と同じく、足すだけ)。
locals {
  services = toset(concat([
    "appengine.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
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
  for_each = toset(var.retiring_services)

  project = var.project_id
  service = each.value

  disable_on_destroy = true
  # bigquery と bigquerystorage のように互いに依存し合うものは、片方ずつは止められない。
  # 依存しているものが一緒に止まるので、外す前に依存先がすべてこの一覧にあることを確かめる。
  disable_dependent_services = true

  lifecycle {
    precondition {
      condition     = !contains(local.services, each.value)
      error_message = "使う API (local.services / extra_services) は止められない。"
    }
  }
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
