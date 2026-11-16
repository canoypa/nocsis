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
      if k != "roles/iam.workloadIdentityPoolViewer serviceAccount:${var.claude_readonly_email}"
    }
    # 取り込みの時点で有効だったものだけ。後から足したものを取り込もうとすると plan が落ちる。
    services = {
      for s in setintersection(local.services, [
        "appengine.googleapis.com", "artifactregistry.googleapis.com", "calendar-json.googleapis.com",
        "cloudbilling.googleapis.com", "cloudbuild.googleapis.com", "containerregistry.googleapis.com",
        "deploymentmanager.googleapis.com", "firebaseextensions.googleapis.com", "firebasestorage.googleapis.com",
        "runtimeconfig.googleapis.com",
        "cloudfunctions.googleapis.com", "cloudresourcemanager.googleapis.com", "cloudscheduler.googleapis.com",
        "eventarc.googleapis.com", "firebase.googleapis.com", "firebasehosting.googleapis.com",
        "firebaserules.googleapis.com", "firestore.googleapis.com", "iam.googleapis.com",
        "iamcredentials.googleapis.com", "identitytoolkit.googleapis.com", "logging.googleapis.com",
        "pubsub.googleapis.com", "run.googleapis.com", "secretmanager.googleapis.com",
        "securetoken.googleapis.com", "serviceusage.googleapis.com", "storage.googleapis.com",
        "sts.googleapis.com",
      ]) : s => "${var.project_id}/${s}"
    }
    retiring_services = { for s in var.retiring_services : s => "${var.project_id}/${s}" }
    audit_log_configs = {
      for s, _ in var.audit_log_configs : s => "${var.project_id} ${s}" if s == "storage.googleapis.com"
    }
    wlif_deploy_acts_as = { for k, v in local.wlif_deploy_acts_as : k => "${v} roles/iam.serviceAccountUser serviceAccount:wlif-deploy@${var.project_id}.iam.gserviceaccount.com" }
  }
}
