terraform {
  backend "gcs" {
    bucket = "class-clock-40088-tfstate"
  }
}

provider "google" {
  project = "class-clock-40088"
  region  = "asia-northeast1"
}

provider "google-beta" {
  project = "class-clock-40088"
  region  = "asia-northeast1"
}

module "nocsis" {
  source = "../modules/nocsis"

  project_id = "class-clock-40088"

  auth_authorized_domains      = ["class-clock-40088.firebaseapp.com", "class-clock-40088.web.app", "nocsis.app"]
  auth_email_password_required = false
  auth_google_client_id        = "219141289630-1duqb26tbk7dte61804hjqg64qmhfsc2.apps.googleusercontent.com"

  hosting_app_id         = "1:219141289630:web:6988629faf082890b1ad8f"
  hosting_custom_domains = ["nocsis.app"]

  # 承認や制限は environment ごとに違う。別の environment のジョブにこの環境へデプロイさせない。
  wlif_deploy_environments = ["Production"]

  secrets = {
    "CALENDAR_ACCOUNT_KEY" = ["backend-runtime", "functions-runtime"]
    "OPENWEATHERMAP_TOKEN" = ["backend-runtime"]
  }

  # events-reader が Google カレンダーを読む。
  extra_services = ["calendar-json.googleapis.com"]

  # DATA_READ / DATA_WRITE はデプロイのたびのソースやイメージの読み書きで量が多く、
  # 見ることがないので記録しない。
  audit_log_configs = {
    "storage.googleapis.com" = ["ADMIN_READ"]
  }

  extra_service_accounts = {
    "events-reader" = {
      display_name = "Events Reader"
      description  = "Google カレンダーから Class Clock のイベントを取得する"
    }
  }
}
