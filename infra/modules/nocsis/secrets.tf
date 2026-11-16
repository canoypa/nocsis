# Secret の入れ物と、誰が読めるかだけを持つ。値 (version) は Terraform に置かない。
# group_* はアプリが実行時に作るので、ここでは扱わない。
locals {
  secret_accessor_members = {
    "backend-runtime"   = google_service_account.this["backend-runtime"].member
    "functions-runtime" = google_service_account.this["functions-runtime"].member
    "compute-default"   = "serviceAccount:${local.compute_default_sa}"
    "appengine-default" = "serviceAccount:${local.appengine_default_sa}"
  }
}

resource "google_secret_manager_secret" "this" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.key

  replication {
    auto {}
  }

  # 消すと値も一緒に消え、戻せない。
  lifecycle {
    prevent_destroy = true
  }
}

# 読める人は binding で全員を書く。member 単位にすると、手で足した人が残り続ける。
resource "google_secret_manager_secret_iam_binding" "accessor" {
  for_each = var.secrets

  secret_id = google_secret_manager_secret.this[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  members   = [for a in each.value : local.secret_accessor_members[a]]
}
