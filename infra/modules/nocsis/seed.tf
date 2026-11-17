# Staging に架空のデータを入れる seed (seed_stg.yml) が借りる SA。本番には作らない。
# wlif-deploy に権限を足さないのは、デプロイの SA にデータとユーザーを書き換える権限まで持たせないため。
# 同じ Staging environment に束縛するので、environment をまたいだ分離にはならない。
# service_accounts.tf の for_each に入れないのは、そちらの SA は既存の取り込み (import_ids) の対象になるため。
locals {
  seed_enabled = var.seed_environment != null

  # custom_roles.tf の custom_roles に混ぜる。
  seed_custom_roles = local.seed_enabled ? {
    # roles/firebaseauth.admin は Auth の設定まで変えられ、ユーザーも消せる。
    authUserSeeder = {
      title       = "Auth user seeder"
      description = "テストユーザーの作成と更新、メールからの uid の引き当てのみ。設定とユーザーの削除には触れない。"
      stage       = "GA"
      permissions = ["firebaseauth.users.create", "firebaseauth.users.get", "firebaseauth.users.update"]
    }
  } : {}
}

resource "google_service_account" "seed" {
  count = local.seed_enabled ? 1 : 0

  account_id   = "wlif-seed"
  display_name = "WLIF: GitHub Actions seed"
  description  = "GitHub Actions の Seed Staging が Workload Identity Federation で借りる。Firestore の読み書きと Auth のユーザー作成・更新のみ。"
}

resource "google_service_account_iam_binding" "seed_wlif" {
  count = local.seed_enabled ? 1 : 0

  service_account_id = google_service_account.seed[0].name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["${local.wlif_environment_principal_prefix}/${var.seed_environment}"]
}

resource "google_project_iam_member" "seed" {
  # ロールは参照にせず名前で書く。参照だと作る前は名前が決まらず、for_each に使えない。
  for_each = local.seed_enabled ? toset([
    "roles/datastore.user",
    "projects/${var.project_id}/roles/authUserSeeder",
  ]) : toset([])

  project = var.project_id
  role    = each.key
  member  = google_service_account.seed[0].member

  depends_on = [google_project_iam_custom_role.this]
}
