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
}
