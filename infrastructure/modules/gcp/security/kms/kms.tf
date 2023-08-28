# create service account
resource "google_service_account" "service_account" {
  account_id   = var.service_account_name
  display_name = "${var.service_account_name} service account"
}

resource "google_kms_key_ring" "keyring" {
  name     = var.keyring_name
  location = var.keyring_location
}

resource "google_kms_crypto_key" "cryptokey" {
  name                       = var.cryptokey_name
  key_ring                   = google_kms_key_ring.keyring.id
  rotation_period            = var.cryptokey_rotation_period
  destroy_scheduled_duration = var.cryptokey_destroy_scheduled_duration
  purpose                    = var.cryptokey_purpose
  version_template {
    algorithm = var.cryptokey_version_template.algorithm
    protection_level = var.cryptokey_version_template.protection_level
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key_iam_binding" "cryptokey_iam_binding" {
  crypto_key_id = google_kms_crypto_key.cryptokey.id
  role          = var.cryptokey_role
  members       = ["serviceAccount:${google_service_account.service_account.email}"]
}

