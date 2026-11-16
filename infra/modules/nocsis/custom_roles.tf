# 既定のロールでは広すぎるところに使う。tfConfigReader は bootstrap が持つ。
locals {
  custom_roles = {
    authConfigDeployer = {
      title       = "Auth config deployer"
      description = "blocking functions の登録に必要な Auth 設定の読み書きのみ。ユーザー情報には触れない。追跡: github.com/canoypa/nocsis/issues/1221"
      stage       = "GA"
      permissions = ["firebaseauth.configs.get", "firebaseauth.configs.update"]
    }
    runIamSetter = {
      title       = "Run IAM setter"
      description = "Cloud Run サービスの invoker 設定に必要。firebase deploy が関数の呼び出し許可を設定する。追跡: github.com/canoypa/nocsis/issues/1221"
      stage       = "GA"
      permissions = ["run.services.setIamPolicy"]
    }
    # roles/viewer は Firestore のドキュメントまで読めるので、設定の読み取りだけを切り出した。
    claudeConfigReader = {
      title       = "Claude config reader"
      description = null
      stage       = "ALPHA"
      permissions = ["datastore.databases.get", "datastore.indexes.list", "firebaseauth.configs.get"]
    }
  }
}

resource "google_project_iam_custom_role" "this" {
  for_each = local.custom_roles

  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  stage       = each.value.stage
  permissions = each.value.permissions
}
