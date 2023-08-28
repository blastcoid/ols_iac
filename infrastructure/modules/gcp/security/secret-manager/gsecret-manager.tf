resource "google_secret_manager_secret" "secret" {
  secret_id = var.feature

  labels = {
    "unit"    = var.unit
    "env"     = var.env
    "code"    = var.code
    "feature" = var.feature
    "name"    = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  annotations = {
    "unit"    = var.unit
    "env"     = var.env
    "code"    = var.code
    "feature" = var.feature
    "name"    = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  secret = google_secret_manager_secret.secret.id

  secret_data = var.secret_data
}
