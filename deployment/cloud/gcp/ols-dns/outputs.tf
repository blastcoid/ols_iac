# create cloud dns outputs from gcd module

output "dns_id" {
  value = module.gcloud_dns.dns_id
}

output "dns_zone_name" {
  value = module.gcloud_dns.dns_zone_name
}

output "dns_name" {
  value = module.gcloud_dns.dns_name
}

output "dns_managed_zone_id" {
  value = module.gcloud_dns.dns_managed_zone_id
}

output "dns_name_servers" {
  value = module.gcloud_dns.dns_name_servers
}

output "dns_zone_visibility" {
  value = module.gcloud_dns.dns_zone_visibility
}