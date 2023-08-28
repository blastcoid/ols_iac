output "private_key" {
  value     = tls_private_key.tls.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = google_compute_instance.instance.network_interface.0.access_config.0.nat_ip
}

#output private ip
output "private_ip" {
  value = google_compute_instance.instance.network_interface.0.network_ip
}