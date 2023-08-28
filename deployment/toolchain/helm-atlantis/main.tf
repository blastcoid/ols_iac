# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "helm/ols-dev-helm-atlantis"
  }
}
# Terraform state data gcloud dns
data "terraform_remote_state" "gcloud_dns_ols" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-dns/ols-dev-gcloud-dns-blast"
  }
}


# create a GKE cluster with 2 node pools
# data "google_secret_manager_secret_version" "github_token" {
#   secret = "github-token"
# }

# data "google_secret_manager_secret_version" "github_secret" {
#   secret = "github-webhook-secret"
# }

data "google_project" "current" {}

# Terraform state data kms cryptokey
data "terraform_remote_state" "kms_ols_cryptokey" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-kms/ols-dev-gcloud-kms-ols"
  }
}

# Load encrypted github token and webhook secret from github.auto.tfvars
variable "github_token_ciphertext" {}
variable "github_secret_ciphertext" {}
variable "atlantis_password_ciphertext" {}

# Decrypt github token and webhook secret using kms cryptokey
data "google_kms_secret" "github_token" {
  crypto_key = data.terraform_remote_state.kms_ols_cryptokey.outputs.cryptokey_id
  ciphertext = var.github_token_ciphertext
}

data "google_kms_secret" "github_secret" {
  crypto_key = data.terraform_remote_state.kms_ols_cryptokey.outputs.cryptokey_id
  ciphertext = var.github_secret_ciphertext
}

data "google_kms_secret" "atlantis_password" {
  crypto_key = data.terraform_remote_state.kms_ols_cryptokey.outputs.cryptokey_id
  ciphertext = var.atlantis_password_ciphertext
}

# deploy atlantis helm chart
module "helm" {
  source                      = "../../modules/compute/helm"
  region                      = "asia-southeast2"
  unit                        = "ols"
  env                         = "dev"
  code                        = "helm"
  feature                     = "atlantis"
  release_name                = "atlantis"
  repository                  = "https://runatlantis.github.io/helm-charts"
  chart                       = "atlantis"
  values                      = ["${file("values.yaml")}"]
  create_gservice_account     = true
  use_gworkload_identity      = true
  project_id                  = data.google_project.current.project_id
  google_service_account_role = "roles/owner"
  dns_name                    = data.terraform_remote_state.gcloud_dns_ols.outputs.dns_name
  create_gmanaged_certificate  = true
  helm_sets = [
    {
      name  = "orgAllowlist"
      value = "github.com/greyhats13/*"
    },
    {
      name  = "github.user"
      value = "greyhats13"
    },
    {
      name  = "github.token"
      value = data.google_kms_secret.github_token.plaintext
    },
    {
      name  = "github.secret"
      value = data.google_kms_secret.github_secret.plaintext
    },
    {
      name  = "ingress.annotations.kubernetes\\.io/ingress\\.class"
      value = "gce"
    },
    {
      name  = "ingress.annotations.networking\\.gke\\.io/managed-certificates"
      value = "atlantis-cert"
    },
    {
      name  = "ingress.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
      value = "atlantis2.ols.blast.co.id"
    },
    {
      name  = "ingress.enabled"
      value = true
    },
    {
      name  = "ingress.host"
      value = "atlantis2.ols.blast.co.id"
    }
  ]
  namespace        = "ci"
  create_namespace = true
}
