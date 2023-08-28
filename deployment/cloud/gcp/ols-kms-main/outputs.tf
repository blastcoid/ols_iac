# create kms_main outputs

output "keyring_id" {
  value = module.kms_main.keyring_id
}

output "cryptokey_id" {
  value = module.kms_main.cryptokey_id
}

output "service_account_id" {
  value = module.kms_main.service_account_id
}

output "service_account_email" {
  value = module.kms_main.service_account_email
}