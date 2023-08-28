resource "google_dns_managed_zone" "gcloud-dns" {
  name          = "${var.unit}-${var.env}-${var.code}-${var.feature}-${var.zone_name}"
  dns_name      = var.dns_name
  description   = var.zone_description
  force_destroy = var.force_destroy
  visibility    = var.visibility
}
