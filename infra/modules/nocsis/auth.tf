resource "google_identity_platform_config" "this" {
  project            = var.project_id
  authorized_domains = var.auth_authorized_domains

  sign_in {
    email {
      enabled           = true
      password_required = var.auth_email_password_required
    }
    phone_number {
      enabled = false
    }
    # 教室ディスプレイの端末が使う。使われなくなったアカウントは functions の定期実行が消す
    anonymous {
      enabled = true
    }
  }

  lifecycle {
    # ブロッキング関数は functions のデプロイ (firebase deploy) が登録する。
    ignore_changes = [blocking_functions]
  }
}

resource "google_identity_platform_default_supported_idp_config" "google" {
  project   = var.project_id
  idp_id    = "google.com"
  enabled   = true
  client_id = var.auth_google_client_id
  # シークレットは Firebase が OAuth クライアントを作ったときに入れたものを使い続ける。
  # Terraform に渡すと Actions の secret が1つ増えるだけで、得るものが無い。
  client_secret = "managed-outside-terraform"

  lifecycle {
    ignore_changes = [client_secret]
  }
}
