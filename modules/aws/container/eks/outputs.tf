# EKS Outputs

output "cluster_arn" {
  value       = aws_eks_cluster.cluster.arn
  description = "EKS Cluster ARN"
}

output "cluster_id" {
  value       = aws_eks_cluster.cluster.id
  description = "EKS Cluster ID"
}

output "cluster_name" {
  value       = aws_eks_cluster.cluster.name
  description = "EKS Cluster Name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.cluster.endpoint
  description = "EKS Cluster Endpoint"
}

output "cluster_kubeconfig_certificate_authority_data" {
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
  description = "EKS Cluster Certificate Authority Data"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  description = "EKS Cluster Security Group ID"
}

# Node Group Outputs

output "cluster_ng_id" {
  value = { for k, v in aws_eks_node_group.ng : k => v.id }
}

output "cluster_ng_arn" {
  value = { for k, v in aws_eks_node_group.ng : k => v.arn }
}

output "cluster_ng_resources" {
  value = { for k, v in aws_eks_node_group.ng : k => v.resources }
}

# OIDC Outputs
output "oidc_provider_url" {
  value       = aws_iam_openid_connect_provider.oidc.url
  description = "OIDC URL"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.oidc.arn
  description = "OIDC ARN"
}

# IAM Role Outputs
output "vpc_cni_role_arn" {
  value       = aws_iam_role.vpc_cni_role.arn
  description = "VPC CNI IAM Role ARN"
}

# Security Group Outputs

output "cluster_sg_id" {
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  description = "EKS Cluster Security Group ID"
}

output "ng_sg_id" {
  value       = aws_security_group.ng.id
  description = "EKS Node Group Security Group ID"
}

output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "ALB Security Group ID"
}
