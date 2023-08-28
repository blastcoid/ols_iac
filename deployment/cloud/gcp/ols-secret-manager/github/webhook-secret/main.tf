# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gsecret-manager/ols-dev-gsecret-manager-github-webhook-secret"
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

# Load encrypted github webhook secret from github.auto.tfvars
variable "github_secret_ciphertext" {}

# Decrypt github webhook secret using kms cryptokey
data "google_kms_secret" "github_secret" {
  crypto_key = data.terraform_remote_state.kms_ols_cryptokey.outputs.cryptokey_id
  ciphertext = var.github_secret_ciphertext
}

module "gsecret-manager" {
  source      = "../../../../modules/security/gsecret-manager"
  region      = "asia-southeast2"
  unit        = "ols"
  env         = "dev"
  code        = "gsecret-manager"
  feature     = "github-webhook-secret"
  secret_data = data.google_kms_secret.github_secret.plaintext
}
