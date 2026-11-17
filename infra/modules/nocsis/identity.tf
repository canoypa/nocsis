# GitHub Actions から GCP に入るための Workload Identity と、そこから引く SA。
# tf-plan / tf-apply 本体と、Terraform を動かすのに要る権限は bootstrap が持つ。Terraform が
# 自分の権限を消して戻せなくなるのを避けるため、ここでは扱わない。後から足す権限は terraform_iam.tf。

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-action"
  display_name              = "GitHub Actions"
  description               = "canoypa/nocsis のワークフローからの認証"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "deploy-nocsis"
  display_name                       = "canoypa/nocsis"

  # リポジトリ名は付け替えられるので、ID でも縛る。
  attribute_condition = "assertion.repository == \"canoypa/nocsis\" && assertion.repository_id == \"515413526\""
  attribute_mapping = {
    "google.subject"        = "assertion.repository"
    "attribute.repository"  = "assertion.repository"
    "attribute.environment" = "has(assertion.environment) ? assertion.environment : \"\""
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  wlif_principal                    = "principal://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/subject/canoypa/nocsis"
  wlif_environment_principal_prefix = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.environment"
}

# build はブランチを問わず PR でも流すので、リポジトリに束縛する。
resource "google_service_account_iam_member" "wlif_build" {
  service_account_id = google_service_account.this["wlif-build"].name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.wlif_principal
}

# deploy は environment の承認を通ったジョブだけが引ける。
# binding (この役割の持ち主をここに書いたものだけにする) にして、手で足された束縛も plan に出す。
resource "google_service_account_iam_binding" "wlif_deploy" {
  service_account_id = google_service_account.this["wlif-deploy"].name
  role               = "roles/iam.workloadIdentityUser"
  members            = [for env in var.wlif_deploy_environments : "${local.wlif_environment_principal_prefix}/${env}"]
}
