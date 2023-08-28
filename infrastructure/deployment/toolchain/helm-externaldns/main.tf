# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "helm/ols-dev-helm-external-dns"
  }
}

data "google_project" "current" {}

# create a GKE cluster with 2 node pools
data "terraform_remote_state" "gcloud_dns_ols" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-dns/ols-dev-gcloud-dns-blast"
  }
}

module "externaldns" {
  source                      = "../../modules/compute/helm"
  region                      = "asia-southeast2"
  unit                        = "ols"
  env                         = "dev"
  code                        = "helm"
  feature                     = "external-dns"
  repository                  = "https://charts.bitnami.com/bitnami"
  chart                       = "external-dns"
  create_gservice_account      = true
  use_gworkload_identity       = true
  project_id                  = data.google_project.current.project_id
  google_service_account_role = "roles/dns.admin"
  create_gmanaged_certificate = false
  values                     = ["${file("values.yaml")}"]
  helm_sets = [
    {
      name  = "provider"
      value = "google"
    },
    {
      name  = "google.project"
      value = data.google_project.current.project_id
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "zoneVisibility"
      value = data.terraform_remote_state.gcloud_dns_ols.outputs.dns_zone_visibility
    }
  ]
  namespace        = "ingress"
  create_namespace = true
}
