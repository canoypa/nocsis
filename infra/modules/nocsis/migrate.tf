# Firestore のデータを書き換えるスクリプト (role_bindings のバックフィルなど) を Actions から流すときに借りる SA。
# wlif-deploy に権限を足さないのは、デプロイの SA のロールをデプロイに要るものだけにしておき、
# データの書き換えが監査ログで別の SA として見分けられるようにするため。
# 同じ environment に束縛するので、デプロイのジョブもこの SA を借りられる。ジョブの間の分離にはならない。
# service_accounts.tf の for_each に入れないのは、そちらの SA は既存の取り込み (import_ids) の対象になるため。
locals {
  migrate_enabled = var.migrate_environment != null
}

resource "google_service_account" "migrate" {
  count = local.migrate_enabled ? 1 : 0

  account_id   = "wlif-migrate"
  display_name = "WLIF: GitHub Actions migrate"
  description  = "GitHub Actions のデータ移行の workflow が Workload Identity Federation で借りる。Firestore の読み書きのみ。"
}

resource "google_service_account_iam_binding" "migrate_wlif" {
  count = local.migrate_enabled ? 1 : 0

  service_account_id = google_service_account.migrate[0].name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["${local.wlif_environment_principal_prefix}/${var.migrate_environment}"]
}

# Firestore の IAM はコレクション単位に絞れない。読み書きを持つ最小のロールにする。
resource "google_project_iam_member" "migrate" {
  count = local.migrate_enabled ? 1 : 0

  project = var.project_id
  role    = "roles/datastore.user"
  member  = google_service_account.migrate[0].member
}
