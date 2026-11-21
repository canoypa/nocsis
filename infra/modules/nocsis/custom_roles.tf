# 既定のロールでは広すぎるところに使う。tfConfigReader は bootstrap が持つ。
locals {
  custom_roles = merge({
    authConfigDeployer = {
      title       = "Auth config deployer"
      description = "blocking functions の登録に必要な Auth 設定の読み書きのみ。ユーザー情報には触れない。"
      stage       = "GA"
      permissions = ["firebaseauth.configs.get", "firebaseauth.configs.update"]
    }
    runIamSetter = {
      title       = "Run IAM setter"
      description = "Cloud Run サービスの invoker 設定に必要。firebase deploy が関数の呼び出し許可を設定する。"
      stage       = "GA"
      permissions = ["run.services.setIamPolicy"]
    }
    secretConfigManager = {
      title       = "Secret config manager"
      description = "Secret の入れ物と、誰が読めるかを管理する。値を読む権限と、消す権限は含めない。"
      stage       = "GA"
      permissions = [
        "secretmanager.secrets.create",
        "secretmanager.secrets.get",
        "secretmanager.secrets.getIamPolicy",
        "secretmanager.secrets.list",
        "secretmanager.secrets.setIamPolicy",
        "secretmanager.secrets.update",
      ]
    }
    # roles/storage.admin はオブジェクトの読み書きまで含むので、バケットの設定だけを切り出した。
    # 消す権限は含めない。
    bucketConfigManager = {
      title       = "Bucket config manager"
      description = "バケットの作成と設定、誰が読み書きできるかを管理する。オブジェクトを読み書きする権限と、消す権限は含めない。"
      stage       = "GA"
      permissions = [
        "storage.buckets.create",
        "storage.buckets.get",
        "storage.buckets.getIamPolicy",
        "storage.buckets.list",
        "storage.buckets.setIamPolicy",
        "storage.buckets.update",
      ]
    }
    # roles/firebaseauth.admin は Auth の設定まで変えられる。
    authUserRemover = {
      title       = "Auth user remover"
      description = "教室ディスプレイの匿名アカウントを確かめて消すための、ユーザーの読み取りと削除のみ。設定には触れない。"
      stage       = "GA"
      permissions = ["firebaseauth.users.delete", "firebaseauth.users.get"]
    }
    # roles/viewer は Firestore のドキュメントまで読めるので、設定の読み取りだけを切り出した。
    claudeConfigReader = {
      title       = "Claude config reader"
      description = null
      stage       = "ALPHA"
      permissions = ["datastore.databases.get", "datastore.indexes.list", "firebaseauth.configs.get"]
    }
  }, local.seed_custom_roles)
}

resource "google_project_iam_custom_role" "this" {
  for_each = local.custom_roles

  role_id     = each.key
  title       = each.value.title
  description = each.value.description
  stage       = each.value.stage
  permissions = each.value.permissions
}
