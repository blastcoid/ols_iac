resource "google_secret_manager_secret" "secret" {
  for_each  = var.secret_data
  secret_id = each.key

  labels = {
    "unit"    = var.standard.unit
    "env"     = var.standard.env
    "code"    = var.standard.code
    "feature" = each.key
    "name"    = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${each.key}"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  annotations = {
    "unit"    = var.standard.unit
    "env"     = var.standard.env
    "code"    = var.standard.code
    "feature" = each.key
    "name"    = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${each.key}"
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  for_each    = var.secret_data
  secret      = google_secret_manager_secret.secret[each.key].id
  secret_data = try(each.value.plaintext, each.value)
}
