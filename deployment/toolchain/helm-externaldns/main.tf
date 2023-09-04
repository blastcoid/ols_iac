# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "toolchain/helm/ols-dev-helm-external-dns"
  }
}

# create a GKE cluster with 2 node pools
data "terraform_remote_state" "dns_blast" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/network/ols-dev-network-dns-blast"
  }
}

module "external-dns" {
  source                      = "../../../modules/cicd/helm"
  region                      = var.region
  env                         = "dev"
  repository                  = "https://charts.bitnami.com/bitnami"
  chart                       = "external-dns"
  service_account_name        = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  create_service_account      = true
  use_workload_identity       = true
  project_id                  = "${var.unit}-platform-${var.env}"
  google_service_account_role = "roles/dns.admin"
  create_managed_certificate = false
  values                      = ["${file("external-dns/values.yaml")}"]
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
      value = data.terraform_remote_state.dns_blast.outputs.dns_zone_visibility
    }
  ]
  namespace        = "ingress"
  create_namespace = true
}
