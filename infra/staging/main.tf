terraform {
  backend "gcs" {
    bucket = "nocsis-development-tfstate"
  }
}

provider "google" {
  project = "nocsis-development"
  region  = "asia-northeast1"
}

provider "google-beta" {
  project = "nocsis-development"
  region  = "asia-northeast1"
}

module "nocsis" {
  source = "../modules/nocsis"

  project_id = "nocsis-development"

  auth_authorized_domains      = ["nocsis-development.firebaseapp.com", "nocsis-development.web.app"]
  auth_email_password_required = true
  auth_google_client_id        = "862064818225-50oucenghkua7qb7hqlpm6vfqp20b6h7.apps.googleusercontent.com"

  # 承認や制限は environment ごとに違う。別の environment のジョブにこの環境へデプロイさせない。
  wlif_deploy_environments = ["Staging"]
  seed_environment         = "Staging"

  secrets = {
    "CALENDAR_ACCOUNT_KEY" = ["backend-runtime", "functions-runtime"]
    "OPENWEATHERMAP_TOKEN" = ["backend-runtime"]
  }

  extra_service_accounts = {
    "claude-readonly" = {
      display_name = "Claude (read-only)"
    }
    "events-reader" = {
      display_name = "Events Reader"
      description  = "Google カレンダーから Class Clock のイベントを取得する"
    }
  }

  # events-reader が Google カレンダーを読む。
  extra_services = ["calendar-json.googleapis.com"]
}
