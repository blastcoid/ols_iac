#create cloud dns outputs

output "dns_id" {
  value = google_dns_managed_zone.gcloud-dns.id
}

output "dns_zone_name" {
  value = google_dns_managed_zone.gcloud-dns.name
}

output "dns_name" {
  value = google_dns_managed_zone.gcloud-dns.dns_name
}

output "dns_managed_zone_id" {
  value = google_dns_managed_zone.gcloud-dns.managed_zone_id
}

output "dns_name_servers" {
  value = google_dns_managed_zone.gcloud-dns.name_servers
}

output "dns_zone_visibility" {
  value = google_dns_managed_zone.gcloud-dns.visibility
}