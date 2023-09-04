# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "toolchain/helm/ols-dev-helm-nginx"
  }
}

data "terraform_remote_state" "dns_blast" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/network/ols-dev-network-dns-blast"
  }
}


data "google_project" "current" {}

module "helm_nginx" {
  source               = "../../../modules/cicd/helm"
  region               = var.region
  env                  = var.env
  repository           = "https://kubernetes.github.io/ingress-nginx"
  chart                = "ingress-nginx"
  service_account_name = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  values               = ["${file("nginx/values.yaml")}"]
  namespace            = "ingress"
  project_id           = data.google_project.current.project_id
  dns_name             = trimsuffix(data.terraform_remote_state.dns_blast.outputs.dns_name, ".")
}
