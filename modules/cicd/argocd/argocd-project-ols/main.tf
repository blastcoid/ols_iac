# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "helm/ols-dev-argocd-project-ols"
  }
}

data "terraform_remote_state" "gcloud_dns_ols" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-dns/ols-dev-gcloud-dns-blast"
  }
}

data "google_project" "current" {}

module "helm" {
  source                      = "../../modules/compute/helm"
  region                      = "asia-southeast2"
  unit                        = "ols"
  env                         = "dev"
  code                        = "argocd"
  feature                     = "project"
  repository                  = "https://argoproj.github.io/argo-helm"
  chart                       = "argocd-apps"
  values                      = ["${file("values.yaml")}"]
  namespace                   = "cd"
  create_namespace            = false
  create_gservice_account     = false
  use_gworkload_identity      = false
  project_id                  = data.google_project.current.project_id
  google_service_account_role = null
  dns_name                    = trimsuffix(data.terraform_remote_state.gcloud_dns_ols.outputs.dns_name, ".")
  create_gmanaged_certificate = false
  extra_vars = {
    github_orgs           = "greyhats13"
    github_repo           = "ol_shop"
    k8s_server            = "https://kubernetes.default.svc"
  }
}
