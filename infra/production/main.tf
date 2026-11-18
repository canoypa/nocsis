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
  migrate_environment      = "Production"

  secrets = {
    "CALENDAR_ACCOUNT_KEY" = ["backend-runtime", "functions-runtime"]
    "OPENWEATHERMAP_TOKEN" = ["backend-runtime"]
  }

  # events-reader が Google カレンダーを読む。
  # firebasestorage は Staging では無効でも困っていないが、本番では firebase deploy が呼んでいるので止めない。
  extra_services = ["calendar-json.googleapis.com", "firebasestorage.googleapis.com"]

  # 使っていない API。取り込みが済んだら、種類ごとに一覧から外して止める。
  retiring_services = [
    "actions.googleapis.com",
    "appenginereporting.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudapis.googleapis.com",
    "fcm.googleapis.com",
    "fcmregistrations.googleapis.com",
    "firebaseappcheck.googleapis.com",
    "firebaseappdistribution.googleapis.com",
    "firebasedataconnect.googleapis.com",
    "firebasedynamiclinks.googleapis.com",
    "firebaseinappmessaging.googleapis.com",
    "firebaseinstallations.googleapis.com",
    "firebaseml.googleapis.com",
    "firebaseremoteconfig.googleapis.com",
    "firebaseremoteconfigrealtime.googleapis.com",
    "googlecloudmessaging.googleapis.com",
    "mlkit.googleapis.com",
    "mobilecrashreporting.googleapis.com",
    "policyanalyzer.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "testing.googleapis.com",
  ]

  # 手で設定していたもの。要るかは別に決める。
  audit_log_configs = {
    "storage.googleapis.com" = ["ADMIN_READ", "DATA_READ", "DATA_WRITE"]
  }

  extra_service_accounts = {
    "events-reader" = {
      display_name = "Events Reader"
      description  = "Google カレンダーから Class Clock のイベントを取得する"
    }
  }
}
