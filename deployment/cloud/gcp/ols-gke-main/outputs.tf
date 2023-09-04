output "compute_cluster_id" {
  description = "The unique identifier of the GKE cluster created by the module."
  value       = module.gke_main.cluster_id
}

output "compute_cluster_name" {
  description = "The name of the GKE cluster created by the module."
  value       = module.gke_main.cluster_name
}

output "compute_cluster_location" {
  description = "The location (region or zone) of the GKE cluster created by the module."
  value       = module.gke_main.cluster_location
}

output "compute_cluster_self_link" {
  description = "The self-link of the GKE cluster created by the module."
  value       = module.gke_main.cluster_self_link
}

output "compute_cluster_endpoint" {
  description = "The IP address of the Kubernetes master endpoint for the GKE cluster."
  value       = module.gke_main.cluster_endpoint
}

output "compute_cluster_client_certificate" {
  description = "The base64-encoded public certificate used by clients to authenticate to the Kubernetes master, created by the module."
  value       = module.gke_main.cluster_client_certificate
}

output "compute_cluster_client_key" {
  description = "The base64-encoded private key used by clients to authenticate to the Kubernetes master, created by the module."
  value       = module.gke_main.cluster_client_key
  sensitive   = true
}

output "compute_cluster_ca_certificate" {
  description = "The base64-encoded public certificate that is the root of trust for the cluster, created by the module."
  value       = module.gke_main.cluster_ca_certificate
}

output "compute_cluster_master_version" {
  description = "The version of the Kubernetes master for the GKE cluster created by the module."
  value       = module.gke_main.cluster_master_version
}