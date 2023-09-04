# create cloud dns outputs from gcd module

output "network_dns_id" {
  value = module.dns_blast.dns_id
}

output "network_dns_zone_name" {
  value = module.dns_blast.dns_zone_name
}

output "network_dns_name" {
  value = module.dns_blast.dns_name
}

output "network_dns_managed_zone_id" {
  value = module.dns_blast.dns_managed_zone_id
}

output "network_dns_name_servers" {
  value = module.dns_blast.dns_name_servers
}

output "network_dns_zone_visibility" {
  value = module.dns_blast.dns_zone_visibility
}