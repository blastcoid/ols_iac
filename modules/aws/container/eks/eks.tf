locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}"
}

resource "aws_eks_cluster" "cluster" {
  name     = var.override_eks_name == null ? "${local.naming_standard}-${var.standard.sub}" : var.override_eks_name
  role_arn = aws_iam_role.eks_role.arn
  version  = var.k8s_version


  dynamic "vpc_config" {
    for_each = toset(var.vpc_config)
    content {
      subnet_ids              = vpc_config.value.subnet_ids
      security_group_ids      = length(vpc_config.value.security_group_ids) > 0 ? vpc_config.value.security_group_ids : [aws_security_group.cluster.id]
      public_access_cidrs     = vpc_config.value.public_access_cidrs
      endpoint_private_access = vpc_config.value.endpoint_private_access
      endpoint_public_access  = vpc_config.value.endpoint_public_access
    }
  }

  dynamic "encryption_config" {
    for_each = toset(var.encryption_config)
    content {
      dynamic "provider" {
        for_each = toset(encryption_config.value.provider)
        content {
          key_arn = provider.value.key_arn
        }
      }
      resources = encryption_config.value.resources
    }
  }

  tags = {
    "Name"    = var.override_eks_name == null ? "${local.naming_standard}-${var.standard.sub}" : var.override_eks_name
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_attachment,
    aws_iam_role_policy_attachment.eks_pods_sg_attachment,
  ]
}
