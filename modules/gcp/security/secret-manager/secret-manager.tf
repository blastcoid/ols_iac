resource "google_secret_manager_secret" "secret" {
  for_each  = var.secret_data
  secret_id = each.key

  labels = {
    "unit"    = split("-", var.secret_name_prefix)[0]
    "env"     = var.env
    "code"    = split("-", var.secret_name_prefix)[2]
    "feature" = each.key
    "name"    = "${var.secret_name_prefix}-${each.key}"
  }

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  annotations = {
    "unit"    = split("-", var.secret_name_prefix)[0]
    "env"     = var.env
    "code"    = split("-", var.secret_name_prefix)[2]
    "feature" = each.key
    "name"    = "${var.secret_name_prefix}-${each.key}"
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  for_each    = var.secret_data
  secret      = google_secret_manager_secret.secret[each.key].id
  secret_data = try(each.value.plaintext, each.value)
}
