resource "google_dns_record_set" "record" {
  name = "${var.subdomain}.${var.dns_name}"
  type = var.record_type
  ttl  = var.ttl

  managed_zone = var.dns_zone_name

  rrdatas = var.rrdatas
}