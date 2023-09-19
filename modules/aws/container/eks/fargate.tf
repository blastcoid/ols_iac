# Create Fargate Profile for EKS Cluster
resource "aws_eks_fargate_profile" "fargate_profile" {
  count                  = length(var.fargate_selectors) > 0 ? 1 : 0
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "${local.naming_standard}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_role.arn
  subnet_ids             = var.vpc_config.subnet_ids

  dynamic "selector" {
    for_each = var.fargate_selectors

    content {
      namespace = selector.value.namespace
      labels    = lookup(selector.value, "labels", {})
    }
  }

  tags = {
    "Name"    = "${local.naming_standard}-fargate-profile"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
  }
}
