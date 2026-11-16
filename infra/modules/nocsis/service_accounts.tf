locals {
  service_accounts = merge({
    "wlif-build" = {
      display_name = "WLIF: GitHub Actions build"
      description  = "GitHub Actions の build ジョブが Workload Identity Federation で借りる。Artifact Registry への push のみ。追跡: github.com/canoypa/nocsis/issues/1221"
    }
    "wlif-deploy" = {
      display_name = "WLIF: GitHub Actions deploy"
      description  = "GitHub Actions の deploy ジョブが Workload Identity Federation で借りる。Cloud Run / Functions / Hosting / Firestore ルール。追跡: github.com/canoypa/nocsis/issues/1221"
    }
    "backend-runtime" = {
      display_name = "backend runtime"
      description  = "Cloud Run の backend が実行時に使う。Firestore とログ、OPENWEATHERMAP_TOKEN / CALENDAR_ACCOUNT_KEY のみ。追跡: github.com/canoypa/nocsis/issues/1221"
    }
    "functions-runtime" = {
      display_name = "functions runtime"
      description  = "Cloud Functions が実行時に使う。Firestore とログ、CALENDAR_ACCOUNT_KEY とグループごとの Slack トークンのみ。追跡: github.com/canoypa/nocsis/issues/1221"
    }
  }, var.extra_service_accounts)

  compute_default_sa   = "${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  appengine_default_sa = "${var.project_id}@appspot.gserviceaccount.com"
}

resource "google_service_account" "this" {
  for_each = local.service_accounts

  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
}

# deploy がサービスや関数をこれらの SA で動かすために要る。
locals {
  wlif_deploy_acts_as = {
    "backend-runtime"   = "projects/${var.project_id}/serviceAccounts/backend-runtime@${var.project_id}.iam.gserviceaccount.com"
    "functions-runtime" = "projects/${var.project_id}/serviceAccounts/functions-runtime@${var.project_id}.iam.gserviceaccount.com"
    "compute-default"   = "projects/${var.project_id}/serviceAccounts/${local.compute_default_sa}"
    "appengine-default" = "projects/${var.project_id}/serviceAccounts/${local.appengine_default_sa}"
  }
}

resource "google_service_account_iam_member" "wlif_deploy_acts_as" {
  for_each = local.wlif_deploy_acts_as

  service_account_id = each.value
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.this["wlif-deploy"].email}"
}
