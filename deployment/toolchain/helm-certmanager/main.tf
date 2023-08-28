# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "helm/ols-dev-helm-cert-manager"
  }
}

data "terraform_remote_state" "gcloud_dns_ols" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-dns/ols-dev-gcloud-dns-blast"
  }
}

module "helm" {
  source                      = "../../modules/compute/helm"
  region                      = "asia-southeast2"
  unit                        = "ols"
  env                         = "dev"
  code                        = "helm"
  feature                     = "cert-manager"
  repository                  = "https://charts.jetstack.io"
  chart                       = "cert-manager"
  values                      = ["${file("values.yaml")}"]
  namespace                   = "ingress"
  after_helm_manifest         = "cluster-issuer.yaml"
}
