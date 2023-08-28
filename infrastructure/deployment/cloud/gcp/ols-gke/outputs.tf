output "cluster_id" {
  description = "The unique identifier of the GKE cluster created by the module."
  value       = module.gkubernetes_engine.cluster_id
}

output "cluster_name" {
  description = "The name of the GKE cluster created by the module."
  value       = module.gkubernetes_engine.cluster_name
}

output "cluster_location" {
  description = "The location (region or zone) of the GKE cluster created by the module."
  value       = module.gkubernetes_engine.cluster_location
}

output "cluster_self_link" {
  description = "The self-link of the GKE cluster created by the module."
  value       = module.gkubernetes_engine.cluster_self_link
}

output "cluster_endpoint" {
  description = "The IP address of the Kubernetes master endpoint for the GKE cluster."
  value       = module.gkubernetes_engine.cluster_endpoint
}

output "cluster_client_certificate" {
  description = "The base64-encoded public certificate used by clients to authenticate to the Kubernetes master, created by the module."
  value       = module.gkubernetes_engine.cluster_client_certificate
}

output "cluster_client_key" {
  description = "The base64-encoded private key used by clients to authenticate to the Kubernetes master, created by the module."
  value       = module.gkubernetes_engine.cluster_client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The base64-encoded public certificate that is the root of trust for the cluster, created by the module."
  value       = module.gkubernetes_engine.cluster_ca_certificate
}

output "cluster_master_version" {
  description = "The version of the Kubernetes master for the GKE cluster created by the module."
  value       = module.gkubernetes_engine.cluster_master_version
}