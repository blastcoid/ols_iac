# EKS Outputs

output "eks_arn" {
  value = aws_eks_cluster.cluster.arn
}

output "eks_id" {
  value = aws_eks_cluster.cluster.id
}

output "eks_cluster_id" {
  value = aws_eks_cluster.cluster.cluster_id
}

output "eks_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "eks_kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}


# Node Group Outputs

# output "eks_ng_id" {
#   value = { for k, v in aws_eks_node_group.ng : k => v.id }
# }

# output "eks_ng_arn" {
#   value = { for k, v in aws_eks_node_group.ng : k => v.arn }
# }

# output "eks_ng_resources" {
#   value = { for k, v in aws_eks_node_group.ng : k => v.resources }
# }
