# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/security/ols-dev-security-secret-managers"
  }
}

# Terraform state data kms cryptokey
data "terraform_remote_state" "kms_ols_cryptokey" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/security/ols-dev-security-kms-main"
  }
}

# Decrypt list of secrets
data "google_kms_secret" "secrets" {
  for_each   = var.secrets_ciphertext
  crypto_key = data.terraform_remote_state.kms_ols_cryptokey.outputs.security_cryptokey_id
  ciphertext = each.value
}

module "secret-manager" {
  source             = "../../../../modules/gcp/security/secret-manager"
  region             = var.region
  env                = var.env
  secret_name_prefix = "${var.unit}-${var.env}-${var.code}"
  secret_data        = data.google_kms_secret.secrets
}
