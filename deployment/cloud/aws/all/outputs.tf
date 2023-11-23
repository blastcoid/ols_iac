# KMS Outputs
output "main_key_id" {
  value = module.kms_main.key_id
}

output "main_key_arn" {
  value = module.kms_main.key_arn
}

# VPC Outputs
output "main_vpc_id" {
  value = module.vpc_main.vpc_id
}

output "main_node_subnet_ids" {
  value = [
    for i in range(length(local.azs)) : module.vpc_main.private_subnets[i]
  ]
}

output "main_node_subnet_arns" {
  value = [
    for i in range(length(local.azs)) : module.vpc_main.private_subnet_arns[i]
  ]
}

# EKS Outputs
output "main_eks_cluster_id" {
  value = module.eks_main.cluster_id
}

output "main_eks_cluster_name" {
  value = module.eks_main.cluster_name
}

output "main_eks_cluster_endpoint" {
  value = module.eks_main.cluster_endpoint
}

output "main_eks_cluster_certificate_authority_data" {
  value = module.eks_main.cluster_certificate_authority_data
}

output "main_eks_oidc_provider" {
  value = module.eks_main.oidc_provider
}

output "main_eks_oidc_provider_arn" {
  value = module.eks_main.oidc_provider_arn
}

output "main_eks_cluster_oidc_issuer_url" {
  value = module.eks_main.cluster_oidc_issuer_url
}

output "main_eks_cluster_version" {
  value = module.eks_main.cluster_version
}