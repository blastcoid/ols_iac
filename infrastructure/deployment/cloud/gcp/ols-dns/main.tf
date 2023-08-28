# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-dns/ols-dev-gcloud-dns-blast"
  }
}

# create cloud dns module

module "gcloud_dns" {
  source           = "../../modules/network/gcloud-dns"
  region           = "asia-southeast2"
  unit             = "ols"
  env              = "dev"
  code             = "gcloud-dns"
  feature          = "blast"
  zone_name        = "ols-blast"
  dns_name         = "ols.blast.co.id."
  zone_description = "Gcloud DNS for for ols.blast.co.id"
  force_destroy    = true
  visibility       = "public"
}
