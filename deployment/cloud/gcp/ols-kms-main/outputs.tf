# create kms_main outputs

output "security_keyring_id" {
  value = module.kms_main.keyring_id
}

output "security_cryptokey_id" {
  value = module.kms_main.cryptokey_id
}

output "security_service_account_id" {
  value = module.kms_main.service_account_id
}

output "security_service_account_email" {
  value = module.kms_main.service_account_email
}