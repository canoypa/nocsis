# プロジェクトに付ける権限。持ち主ごとに並べる。
# member 単位で足すだけなので、ここに無い権限 (Google 管理の SA、owner など) は消さない。
# tf-plan / tf-apply の分は bootstrap と terraform_iam.tf が持つ。
locals {
  project_roles = {
    "serviceAccount:wlif-deploy@${var.project_id}.iam.gserviceaccount.com" = [
      "projects/${var.project_id}/roles/authConfigDeployer",
      "projects/${var.project_id}/roles/runIamSetter",
      "roles/cloudbuild.builds.editor",
      "roles/cloudfunctions.developer",
      "roles/cloudscheduler.admin",
      "roles/datastore.indexAdmin",
      "roles/firebasehosting.admin",
      "roles/firebaserules.admin",
      "roles/run.developer",
      "roles/secretmanager.viewer",
      "roles/storage.bucketViewer",
    ]
    "serviceAccount:backend-runtime@${var.project_id}.iam.gserviceaccount.com" = [
      "projects/${var.project_id}/roles/authUserRemover",
      "roles/datastore.user",
      "roles/logging.logWriter",
    ]
    "serviceAccount:functions-runtime@${var.project_id}.iam.gserviceaccount.com" = [
      "projects/${var.project_id}/roles/authUserRemover",
      "roles/datastore.user",
      "roles/logging.logWriter",
    ]
    # Cloud Functions のビルドがこの SA で動く。
    "serviceAccount:${local.compute_default_sa}" = [
      "roles/artifactregistry.writer",
      "roles/logging.logWriter",
      "roles/storage.objectViewer",
    ]
    # このクラウド環境の閲覧用。Firestore のドキュメントと Secret の値は読めない。
    "serviceAccount:${var.claude_readonly_email}" = [
      "projects/${var.project_id}/roles/claudeConfigReader",
      "roles/errorreporting.viewer",
      "roles/firebasehosting.viewer",
      "roles/iam.securityReviewer",
      "roles/iam.workloadIdentityPoolViewer",
      "roles/logging.viewer",
      "roles/run.viewer",
      "roles/secretmanager.viewer",
      "roles/serviceusage.serviceUsageViewer",
    ]
  }

  project_iam_members = merge([
    for member, roles in local.project_roles : {
      for role in roles : "${role} ${member}" => { role = role, member = member }
    }
  ]...)
}

resource "google_project_iam_member" "this" {
  for_each = local.project_iam_members

  project = var.project_id
  role    = each.value.role
  member  = each.value.member

  depends_on = [google_project_iam_custom_role.this]
}
