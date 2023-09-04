# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "toolchain/helm/ols-dev-helm-argocd"
  }
}

data "terraform_remote_state" "dns_blast" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/network/ols-dev-network-dns-blast"
  }
}

data "google_secret_manager_secret_version" "github_oauth_client_secret_argocd" {
  secret = "github-oauth-client-secret-argocd"
}

data "google_secret_manager_secret_version" "github_secret" {
  secret = "github-secret"
}

module "helm_argocd" {
  source                      = "../../../modules/cicd/helm"
  region                      = var.region
  env                         = var.env
  repository                  = "https://argoproj.github.io/argo-helm"
  chart                       = "argo-cd"
  service_account_name        = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  values                      = ["${file("argocd/values.yaml")}"]
  namespace                   = "cd"
  create_namespace            = true
  create_service_account      = true
  use_workload_identity       = true
  project_id                  = "${var.unit}-platform-${var.env}"
  google_service_account_role = "roles/container.admin"
  dns_name                    = trimsuffix(data.terraform_remote_state.dns_blast.outputs.dns_name, ".")
  extra_vars = {
    github_orgs      = "blastcoid"
    github_client_id = "9781757e794562ceb7e1"
  }
  helm_sets_sensitive = [
    {
      name  = "configs.secret.githubSecret"
      value = data.google_secret_manager_secret_version.github_secret.secret_data
    },
    {
      name  = "configs.secret.extra.dex\\.github\\.clientSecret"
      value = data.google_secret_manager_secret_version.github_oauth_client_secret_argocd.secret_data
    }
  ]
}
