locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}"
}

resource "aws_eks_cluster" "cluster" {
  name     = var.override_eks_name == null ? "${local.naming_standard}-${var.standard.sub}" : var.override_eks_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = var.cluster_version


  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids              = vpc_config.value.subnet_ids
      security_group_ids      = vpc_config.value.security_group_ids
      public_access_cidrs     = vpc_config.value.public_access_cidrs
      endpoint_private_access = vpc_config.value.endpoint_private_access
      endpoint_public_access  = vpc_config.value.endpoint_public_access
    }
  }

  dynamic "encryption_config" {
    for_each = var.key_arn != null ? [1] : []
    content {
      provider {
        key_arn = var.key_arn
      }
      resources = ["secrets"]
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
    aws_iam_role_policy_attachment.eks_service_policy_attachment,
    aws_iam_role_policy_attachment.eks_pods_sg_attachment,
    aws_kms_grant.grant_cluster
  ]
}
