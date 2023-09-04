# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "toolchain/helm/ols-dev-helm-cert-manager"
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
module "helm_certmanager" {
  source               = "../../../modules/cicd/helm"
  region               = var.region
  env                  = var.env
  repository           = "https://charts.jetstack.io"
  chart                = "cert-manager"
  service_account_name = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  project_id           = "${var.unit}-platform-${var.env}"
  values               = ["${file("cert_manager/values.yaml")}"]
  namespace            = "ingress"
  after_crd_installed  = "cluster-issuer.yaml"
}
