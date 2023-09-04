# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/network/ols-dev-network-dns-blast"
  }
}

# create cloud dns module

module "dns_blast" {
  source             = "../../../../modules/gcp/network/dns"
  region             = var.region
  zone_name          = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  zone_dns_name      = "${var.env}.${var.unit}.blast.co.id."
  zone_description   = "Cloud DNS for for ${var.env}.${var.unit}.blast.co.id."
  zone_force_destroy = true
  zone_visibility    = "public"
}