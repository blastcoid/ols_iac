# Check whether the current environment is running on EC2 or not
data "external" "is_running_on_ec2" {
  program = ["bash", "-c", "curl -s -m 1 http://169.254.169.254/latest/meta-data/instance-id &>/dev/null && echo '{\"on_ec2\": \"true\"}' || echo '{\"on_ec2\": \"false\"}'"]
}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}

# Get availability zones
data "aws_availability_zones" "az" {}

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


# Get KMS secrets values
data "aws_kms_secrets" "secrets" {
  for_each = var.secrets_ciphertext
  secret {
    name    = each.key
    payload = each.value
  }
}

# External DNS IAM Policy

data "aws_iam_policy_document" "externaldns_policy" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [module.route53_main.route53_arn]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = [
      "*",
    ]
  }
}

# Get EKS cluster auth
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_main.cluster_id
}
