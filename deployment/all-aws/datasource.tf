# Get the current AWS account ID
data "aws_caller_identity" "current" {}

# Bucket Policy
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowUserIacAccessToBucket"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/iac",
      ]
    }

    actions = [
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      module.s3_bucket_tfstate.bucket_arn,
      "${module.s3_bucket_tfstate.bucket_arn}/*"
    ]
  }
}

data "aws_kms_secrets" "secrets" {
  for_each = var.secrets_ciphertext
  secret {
    name    = each.key
    payload = each.value
  }
}

