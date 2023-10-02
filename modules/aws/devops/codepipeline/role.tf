resource "aws_iam_role" "role" {
  name               = "${var.name}-cp-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.standard
}

resource "aws_iam_role_policy" "policy" {
  name   = "${var.name}-cp-policy"
  role   = aws_iam_role.role.id
  policy = var.codepipeline_policy
}

resource "aws_kms_grant" "grant" {
  name              = "${var.name}-cp-kms-grant"
  key_id            = var.artifact_store.encryption_key.id
  grantee_principal = aws_iam_role.role.arn
  operations        = var.kms_grant_operations
  # constraints {
  #   encryption_context_equals = {
  #     Department = "Finance"
  #   }
  # }
}
