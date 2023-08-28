resource "google_compute_managed_ssl_certificate" "gcm" {
  name = "${var.unit}-${var.env}-${var.code}-${var.feature}-${var.gcm_name}"
  description = "Managed SSL Certificate for ${var.unit}-${var.env}-${var.code}-${var.feature}-${var.gcm_name}"
  managed {
    domains = var.gcm_domains
  }
}