# Outputs for the VPC Deployment

# VPC Outputs
output "network_vpc_id" {
  value       = module.vpc_main.vpc_id
  description = "The unique identifier of the VPC."
}

output "network_vpc_self_link" {
  value       = module.vpc_main.vpc_self_link
  description = "The URI of the VPC in GCP."
}

output "network_vpc_gateway_ipv4" {
  value       = module.vpc_main.vpc_gateway_ipv4
  description = "The IPv4 address of the VPC's default internet gateway."
}

# Subnetwork Outputs
output "network_subnet_self_link" {
  value       = module.vpc_main.subnet_self_link
  description = "The URI of the subnetwork in GCP."
}

output "network_subnet_ip_cidr_range" {
  value       = module.vpc_main.subnet_ip_cidr_range
  description = "The primary IP CIDR range of the subnetwork."
}

output "network_pods_secondary_range_name" {
  value       = module.vpc_main.pods_secondary_range_name
  description = "The name of the secondary IP range for pods."
}

output "network_services_secondary_range_name" {
  value       = module.vpc_main.services_secondary_range_name
  description = "The name of the secondary IP range for services."
}

# Router Outputs
output "network_router_id" {
  value       = module.vpc_main.router_id
  description = "The unique identifier of the router."
}

output "network_router_self_link" {
  value       = module.vpc_main.router_self_link
  description = "The URI of the router in GCP."
}

# NAT Outputs
output "network_nat_id" {
  value       = module.vpc_main.nat_id
  description = "The unique identifier of the NAT."
}

# Firewall Outputs
output "network_firewall_ids" {
  value       = module.vpc_main.firewall_ids
  description = "The unique identifier of the firewall rule"
}

output "network_firewall_self_links" {
  value       = module.vpc_main.firewall_self_links
  description = "The URI of the firewall rule"
}
