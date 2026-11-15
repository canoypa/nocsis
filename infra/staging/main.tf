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
}
