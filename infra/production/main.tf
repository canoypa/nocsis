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
}
