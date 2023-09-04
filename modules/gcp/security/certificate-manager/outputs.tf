output "certificate_id" {
  value = google_compute_managed_ssl_certificate.certificate.id
}

output "certificate_name" {
  value = google_compute_managed_ssl_certificate.certificate.name
}

output "certificate_certificate_id" {
  value = google_compute_managed_ssl_certificate.certificate.certificate_id
}