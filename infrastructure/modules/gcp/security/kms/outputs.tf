# service account outputs
output "service_account_id" {
  value = google_service_account.service_account.id
}

output "service_account_email" {
  value = google_service_account.service_account.email
}

# keyring outputs
output "keyring_id" {
  value = google_kms_key_ring.keyring.id
}

# cryptokey outputs
output "cryptokey_id" {
  value = google_kms_crypto_key.cryptokey.id
}

