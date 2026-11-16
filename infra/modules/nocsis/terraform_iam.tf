# tf-apply / tf-plan 自身の権限のうち、bootstrap が付けないもの。
# 管理対象を増やすときは、取り込み (import) より先にここで権限を足して apply しておく。
# 取り込みは apply の plan で読みに行くため、同じ apply では間に合わない。
locals {
  tf_apply_member = "serviceAccount:tf-apply@${var.project_id}.iam.gserviceaccount.com"

  tf_apply_roles = [
    # Auth の設定だけを読み書きする。roles/firebaseauth.admin はユーザーまで触れるので使わない。
    "projects/${var.project_id}/roles/authConfigDeployer",
    "roles/firebasehosting.admin",
    # Secret の値は Terraform に置かない。roles/secretmanager.admin は値を読む権限まで含むので使わない。
    "projects/${var.project_id}/roles/secretConfigManager",
    "projects/${var.project_id}/roles/bucketConfigManager",
  ]

  # tf-plan も、管理するリソースの設定を読めないと plan が落ちる。
  # バケットの IAM は bootstrap が付ける roles/iam.securityReviewer で読める。
  tf_plan_member = "serviceAccount:tf-plan@${var.project_id}.iam.gserviceaccount.com"

  tf_plan_roles = [
    "roles/storage.bucketViewer",
  ]
}

resource "google_project_iam_member" "tf_apply" {
  for_each = toset(local.tf_apply_roles)

  project = var.project_id
  role    = each.key
  member  = local.tf_apply_member

  # ロールの名前を文字列で書いているので、作る順番だけを指定する。
  # 参照にすると、作る前は名前が決まらず for_each に使えない。
  depends_on = [google_project_iam_custom_role.this]
}

resource "google_project_iam_member" "tf_plan" {
  for_each = toset(local.tf_plan_roles)

  project = var.project_id
  role    = each.key
  member  = local.tf_plan_member
}
