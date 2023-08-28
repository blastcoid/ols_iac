# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gsecret-manager/ols-dev-gsecret-manager-atlantis-password"
  }
}

# Terraform state data kms cryptokey
data "terraform_remote_state" "kms_ols_cryptokey" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-kms/ols-dev-gcloud-kms-ols"
  }
}

# Load encrypted atlantis password from atlantis_password.auto.tfvars
variable "atlantis_password_ciphertext" {}

# Decrypt github token and webhook secret using kms cryptokey
data "google_kms_secret" "atlantis_password" {
  crypto_key = data.terraform_remote_state.kms_ols_cryptokey.outputs.cryptokey_id
  ciphertext = var.atlantis_password_ciphertext
}

module "gsecret-manager" {
  source      = "../../../modules/security/gsecret-manager"
  region      = "asia-southeast2"
  unit        = "ols"
  env         = "dev"
  code        = "gsecret-manager"
  feature     = "atlantis-password"
  secret_data = data.google_kms_secret.atlantis_password.plaintext
}
