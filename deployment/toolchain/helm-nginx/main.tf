# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "helm/ols-dev-helm-nginx"
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
  code                        = "helm"
  feature                     = "nginx"
  repository                  = "https://kubernetes.github.io/ingress-nginx"
  chart                       = "ingress-nginx"
  values                      = ["${file("values.yaml")}"]
  namespace                   = "ingress"
  create_namespace            = false
  create_gservice_account     = false
  use_gworkload_identity      = false
  project_id                  = data.google_project.current.project_id
  google_service_account_role = null
  dns_name                    = trimsuffix(data.terraform_remote_state.gcloud_dns_ols.outputs.dns_name, ".")
  create_gmanaged_certificate  = false
}