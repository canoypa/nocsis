output "project_number" {
  value = data.google_project.this.number
}

# 取り込み (#1406) の import ブロック用。取り込みが済んだら、各環境の imports.tf と一緒に消す。
output "import_ids" {
  value = {
    service_accounts = { for id, _ in local.service_accounts : id => "projects/${var.project_id}/serviceAccounts/${id}@${var.project_id}.iam.gserviceaccount.com" }
    custom_roles     = { for id, _ in local.custom_roles : id => "projects/${var.project_id}/roles/${id}" }
    # この PR で新しく足す権限は、取り込むものが無いので除く。
    project_iam = {
      for k, v in local.project_iam_members : k => "${var.project_id} ${v.role} ${v.member}"
      if k != "roles/iam.workloadIdentityPoolViewer serviceAccount:${var.claude_readonly_email}"
    }
    wlif_deploy_acts_as = { for k, v in local.wlif_deploy_acts_as : k => "${v} roles/iam.serviceAccountUser serviceAccount:wlif-deploy@${var.project_id}.iam.gserviceaccount.com" }
  }
}
