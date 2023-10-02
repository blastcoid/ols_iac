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

# get data aws ssms parameter store
data "aws_ssm_parameter" "github_secret" {
  name = "/${var.standard.Unit}/${var.standard.Env}/${var.standard.Code}/${var.standard.Feature}/github/GITHUB_SECRET"
}