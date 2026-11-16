resource "google_firebase_hosting_site" "default" {
  provider = google-beta
  project  = var.project_id
  site_id  = var.project_id
  app_id   = var.hosting_app_id
}

resource "google_firebase_hosting_custom_domain" "this" {
  provider = google-beta
  for_each = toset(var.hosting_custom_domains)

  project       = var.project_id
  site_id       = google_firebase_hosting_site.default.site_id
  custom_domain = each.key
}
