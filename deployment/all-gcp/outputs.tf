# Outputs for the VPC Deployment

# VPC Outputs
output "main_vpc_id" {
  value       = module.vpc_main.vpc_id
  description = "The unique identifier of the VPC."
}

output "main_vpc_self_link" {
  value       = module.vpc_main.vpc_self_link
  description = "The URI of the VPC in GCP."
}

output "main_vpc_gateway_ipv4" {
  value       = module.vpc_main.vpc_gateway_ipv4
  description = "The IPv4 address of the VPC's default internet gateway."
}

# Subnetwork Outputs
output "main_subnet_self_link" {
  value       = module.vpc_main.subnet_self_link
  description = "The URI of the subnetwork in GCP."
}

output "main_subnet_ip_cidr_range" {
  value       = module.vpc_main.subnet_ip_cidr_range
  description = "The primary IP CIDR range of the subnetwork."
}

output "main_pods_secondary_range_name" {
  value       = module.vpc_main.pods_secondary_range_name
  description = "The name of the secondary IP range for pods."
}

output "main_services_secondary_range_name" {
  value       = module.vpc_main.services_secondary_range_name
  description = "The name of the secondary IP range for services."
}

# Router Outputs
output "main_router_id" {
  value       = module.vpc_main.router_id
  description = "The unique identifier of the router."
}

output "main_router_self_link" {
  value       = module.vpc_main.router_self_link
  description = "The URI of the router in GCP."
}

# NAT Outputs
output "main_nat_id" {
  value       = module.vpc_main.nat_id
  description = "The unique identifier of the NAT."
}

# Firewall Outputs
output "main_firewall_ids" {
  value       = module.vpc_main.firewall_ids
  description = "The unique identifier of the firewall rule"
}

output "main_firewall_self_links" {
  value       = module.vpc_main.firewall_self_links
  description = "The URI of the firewall rule"
}

# Cloud dns outputs
## blast zone
output "blast_dns_id" {
  value = module.dns_blast.dns_id
}

output "blast_dns_zone_name" {
  value = module.dns_blast.dns_zone_name
}

output "blast_dns_name" {
  value = module.dns_blast.dns_name
}

output "blast_dns_managed_zone_id" {
  value = module.dns_blast.dns_managed_zone_id
}

output "blast_dns_name_servers" {
  value = module.dns_blast.dns_name_servers
}

output "blast_dns_zone_visibility" {
  value = module.dns_blast.dns_zone_visibility
}
## gke zone
output "blast_private_dns_id" {
  value = module.blast_private_zone.dns_id
}

output "blast_private_dns_zone_name" {
  value = module.blast_private_zone.dns_zone_name
}

output "blast_private_dns_name" {
  value = module.blast_private_zone.dns_name
}

output "blast_private_dns_managed_zone_id" {
  value = module.blast_private_zone.dns_managed_zone_id
}

output "blast_private_dns_name_servers" {
  value = module.blast_private_zone.dns_name_servers
}

output "blast_private_dns_zone_visibility" {
  value = module.blast_private_zone.dns_zone_visibility
}

# Secret manager outputs
output "main_secret_id" {
  value = module.secret-manager.secret_id
}

output "main_secret_version_id" {
  value = module.secret-manager.secret_version_id
}

output "main_secret_version_data" {
  value     = module.secret-manager.secret_version_data
  sensitive = true
}

# GKE Outputs
output "main_cluster_id" {
  description = "The unique identifier of the GKE cluster created by the module."
  value       = module.gke_main.cluster_id
}

output "main_cluster_name" {
  description = "The name of the GKE cluster created by the module."
  value       = module.gke_main.cluster_name
}

output "main_cluster_location" {
  description = "The location (region or zone) of the GKE cluster created by the module."
  value       = module.gke_main.cluster_location
}

output "main_cluster_self_link" {
  description = "The self-link of the GKE cluster created by the module."
  value       = module.gke_main.cluster_self_link
}

output "main_cluster_endpoint" {
  description = "The IP address of the Kubernetes master endpoint for the GKE cluster."
  value       = module.gke_main.cluster_endpoint
}

output "main_cluster_client_certificate" {
  description = "The base64-encoded public certificate used by clients to authenticate to the Kubernetes master, created by the module."
  value       = module.gke_main.cluster_client_certificate
}

output "main_cluster_client_key" {
  description = "The base64-encoded private key used by clients to authenticate to the Kubernetes master, created by the module."
  value       = module.gke_main.cluster_client_key
  sensitive   = true
}

output "main_cluster_ca_certificate" {
  description = "The base64-encoded public certificate that is the root of trust for the cluster, created by the module."
  value       = module.gke_main.cluster_ca_certificate
}

output "main_cluster_master_version" {
  description = "The version of the Kubernetes master for the GKE cluster created by the module."
  value       = module.gke_main.cluster_master_version
}