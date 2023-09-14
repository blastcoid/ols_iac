data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "${local.naming_standard}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = {
    "Name"    = local.naming_standard
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = var.standard.sub
    "Service" = var.standard.name
  }
}

resource "aws_iam_role_policy" "policy" {
  name   = "${local.naming_standard}-policy"
  role   = aws_iam_role.role.id
  policy = var.codepipeline_policy
}

resource "aws_kms_grant" "grant" {
  name              = "${local.naming_standard}-kms-grant"
  key_id            = var.artifact_store.encryption_key.id
  grantee_principal = aws_iam_role.role.arn
  operations        = var.kms_grant_operations
  # constraints {
  #   encryption_context_equals = {
  #     Department = "Finance"
  #   }
  # }
}
