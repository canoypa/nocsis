output "project_number" {
  value = data.google_project.this.number
}

# 取り込みの import ブロック用。取り込みが済んだら、各環境の imports.tf と一緒に消す。
output "import_ids" {
  value = {
    service_accounts = { for id, _ in local.service_accounts : id => "projects/${var.project_id}/serviceAccounts/${id}@${var.project_id}.iam.gserviceaccount.com" }
    # 取り込みの時点で GCP にあったロールだけ。
    custom_roles = { for id in ["authConfigDeployer", "runIamSetter", "claudeConfigReader"] : id => "projects/${var.project_id}/roles/${id}" }
    # 取り込みの後に新しく足した権限は除く。
    project_iam = {
      for k, v in local.project_iam_members : k => "${var.project_id} ${v.role} ${v.member}"
      if !contains([
        "roles/errorreporting.viewer serviceAccount:${var.claude_readonly_email}",
        "roles/iam.workloadIdentityPoolViewer serviceAccount:${var.claude_readonly_email}",
        "projects/${var.project_id}/roles/authUserRemover serviceAccount:backend-runtime@${var.project_id}.iam.gserviceaccount.com",
        "projects/${var.project_id}/roles/authUserRemover serviceAccount:functions-runtime@${var.project_id}.iam.gserviceaccount.com",
      ], k)
    }
    # 取り込みの後に足した API は除く。まだ無効な環境で取り込もうとすると plan が落ちる。
    services          = { for s in setsubtract(local.services, ["clouderrorreporting.googleapis.com"]) : s => "${var.project_id}/${s}" }
    retiring_services = { for s in var.retiring_services : s => "${var.project_id}/${s}" }
    audit_log_configs = {
      for s, _ in var.audit_log_configs : s => "${var.project_id} ${s}" if s == "storage.googleapis.com"
    }
    wlif_deploy_acts_as = { for k, v in local.wlif_deploy_acts_as : k => "${v} roles/iam.serviceAccountUser serviceAccount:wlif-deploy@${var.project_id}.iam.gserviceaccount.com" }
  }
}
