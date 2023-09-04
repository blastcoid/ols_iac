#create cloud dns outputs

output "dns_id" {
  value = google_dns_managed_zone.zone.id
}

output "dns_zone_name" {
  value = google_dns_managed_zone.zone.name
}

output "dns_name" {
  value = google_dns_managed_zone.zone.dns_name
}

output "dns_managed_zone_id" {
  value = google_dns_managed_zone.zone.managed_zone_id
}

output "dns_name_servers" {
  value = google_dns_managed_zone.zone.name_servers
}

output "dns_zone_visibility" {
  value = google_dns_managed_zone.zone.visibility
}