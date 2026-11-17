# フロントエンドのソースマップを置く。backend がエラーのスタックトレースを解読するのに読む。
# 名前は backend の AppConfig.SOURCE_MAP_BUCKET_SUFFIX と揃える。
# ソースマップはシンボル名とパスが読めるので、公開しない。
resource "google_storage_bucket" "source_maps" {
  name     = "${var.project_id}-frontend-source-maps"
  location = var.region

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # 期限は置いた日から数えるので、デプロイが止まると動いている版のものまで消える。
  # 1 年デプロイしないことは考えにくく、残しても 1 回のデプロイで数 MB にしかならない。
  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

# このバケットのために足す権限は binding で全員を書く。member 単位にすると、手で足した人が残り続ける。
# プロジェクトに付いた権限 (owner や、関数のビルドが使う compute の既定 SA の objectViewer) でも読める。
# deploy は置くだけで、上書きと削除はできない。消せると、deploy の権限で過去のソースマップを消せてしまう。
# 同じ commit のデプロイをやり直したときは、置く側が既にあるものを飛ばす。その確かめに読み取りが要る。
resource "google_storage_bucket_iam_binding" "source_maps_creator" {
  bucket  = google_storage_bucket.source_maps.name
  role    = "roles/storage.objectCreator"
  members = [google_service_account.this["wlif-deploy"].member]
}

resource "google_storage_bucket_iam_binding" "source_maps_viewer" {
  bucket  = google_storage_bucket.source_maps.name
  role    = "roles/storage.objectViewer"
  members = [
    google_service_account.this["backend-runtime"].member,
    google_service_account.this["wlif-deploy"].member,
  ]
}
