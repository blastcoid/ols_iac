# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gsecret-manager/ols-dev-gsecret-manager-github-oauth-client-secret-argocd"
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

# Load encrypted github oauth client secret for argocd
variable "github_oauth_client_secret_argocd_ciphertext" {}

# Decrypt github oauth client secret using kms cryptokey
data "google_kms_secret" "github_oauth_client_secret_argocd" {
  crypto_key = data.terraform_remote_state.kms_ols_cryptokey.outputs.cryptokey_id
  ciphertext = var.github_oauth_client_secret_argocd_ciphertext
}

module "gsecret-manager" {
  source      = "../../../../modules/security/gsecret-manager"
  region      = "asia-southeast2"
  unit        = "ols"
  env         = "dev"
  code        = "gsecret-manager"
  feature     = "github-oauth-client-secret-argocd"
  secret_data = data.google_kms_secret.github_oauth_client_secret_argocd.plaintext
}
