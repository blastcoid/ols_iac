# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "helm/ols-dev-helm-argo-cd"
  }
}

data "terraform_remote_state" "gcloud_dns_ols" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-dns/ols-dev-gcloud-dns-blast"
  }
}

data "google_secret_manager_secret_version" "github_oauth_client_secret_argocd" {
  secret = "github-oauth-client-secret-argocd"
}

data "google_secret_manager_secret_version" "github_secret" {
  secret = "github-webhook-secret"
}

data "google_project" "current" {}

module "helm" {
  source                      = "../../modules/compute/helm"
  region                      = "asia-southeast2"
  unit                        = "ols"
  env                         = "dev"
  code                        = "helm"
  feature                     = "argocd"
  repository                  = "https://argoproj.github.io/argo-helm"
  chart                       = "argo-cd"
  values                      = ["${file("values.yaml")}"]
  namespace                   = "cd"
  create_namespace            = true
  create_gservice_account     = true
  use_gworkload_identity      = true
  project_id                  = data.google_project.current.project_id
  google_service_account_role = "roles/container.admin"
  dns_name                    = trimsuffix(data.terraform_remote_state.gcloud_dns_ols.outputs.dns_name, ".")
  create_gmanaged_certificate = false
  values_extra_vars = {
    github_orgs           = "blastcoid"
    github_client_id      = "9781757e794562ceb7e1"
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
