# VPC output
output "vpc_id" {
  value       = google_compute_network.vpc.id
  description = "The ID of the VPC being created."
}

output "vpc_self_link" {
  value       = google_compute_network.vpc.self_link
  description = "The URI of the VPC being created."
}

output "vpc_gateway_ipv4" {
  value       = google_compute_network.vpc.gateway_ipv4
  description = "The IPv4 address of the VPC's gateway."
}

# Subnetwork output
output "subnet_network" {
  value       = google_compute_subnetwork.subnet.network
  description = "The network to which this subnetwork belongs."
}

output "subnet_self_link" {
  value       = google_compute_subnetwork.subnet.self_link
  description = "The URI of the subnetwork."
}

output "subnet_ip_cidr_range" {
  value       = google_compute_subnetwork.subnet.ip_cidr_range
  description = "The IP CIDR range of the subnetwork."
}

output "pods_secondary_range_name" {
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
  description = "The name of the secondary IP range for pods."
}

output "services_secondary_range_name" {
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
  description = "The name of the secondary IP range for services."
}

# Router output
output "router_id" {
  value       = google_compute_router.router.id
  description = "The ID of the router being created."
}

output "router_self_link" {
  value       = google_compute_router.router.self_link
  description = "The URI of the router being created."
}

# NAT output
output "nat_id" {
  value       = google_compute_router_nat.nat.id
  description = "The ID of the NAT being created."
}

# Firewall output
output "firewall_ids" {
  description = "Map of firewall rule IDs."
  value       = { for key, rule in google_compute_firewall.firewall : key => rule.id }
}

output "firewall_self_links" {
  description = "Map of firewall rule self links."
  value       = { for key, rule in google_compute_firewall.firewall : key => rule.self_link }
}
