data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.namespace}:${local.helm_naming_standard}"]
    }

    principals {
      identifiers = [var.eks_oidc_arn]
      type        = "Federated"
    }
  }
}

# IAM role for helm service account
resource "aws_iam_role" "role" {
  count              = var.cloud_provider == "aws" && var.create_service_account ? 1 : 0
  name               = "${local.helm_naming_standard}-iam-role"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
}

# IAM policy for helm service account
resource "aws_iam_policy" "policy" {
  count       = var.cloud_provider == "aws" && var.create_service_account ? 1 : 0
  name        = "${local.helm_naming_standard}-iam-policy"
  description = "IAM policy for ${local.helm_naming_standard}-iam-policy"
  policy      = var.iam_policy
}

# Attach IAM policy to helm service account
resource "aws_iam_role_policy_attachment" "helm_role_policy" {
  count      = var.cloud_provider == "aws" && var.create_service_account ? 1 : 0
  role       = aws_iam_role.role[count.index].name
  policy_arn = aws_iam_policy.policy[count.index].arn
}
