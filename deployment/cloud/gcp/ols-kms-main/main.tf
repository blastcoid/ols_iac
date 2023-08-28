# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/security/ols-dev-security-kms-main"
  }
}

# create cloud kms module
module "kms_main" {
  source                               = "../../../../modules/gcp/security/kms"
  region                               = "asia-southeast2"
  project_id                           = "${var.unit}-platform-${var.env}"
  service_account_name                 = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
  keyring_name                         = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}"
  keyring_location                     = "global"
  cryptokey_name                       = "${var.unit}-${var.env}-${var.code}-${var.feature[2]}"
  cryptokey_rotation_period            = "2592000s"
  cryptokey_destroy_scheduled_duration = "86400s"
  cryptokey_purpose                    = "ENCRYPT_DECRYPT"
  cryptokey_version_template = {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
  cryptokey_role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}
