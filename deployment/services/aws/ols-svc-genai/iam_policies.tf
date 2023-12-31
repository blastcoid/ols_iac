# # Bucket policy
# data "aws_iam_policy_document" "custom_bucket_policy" {
#   statement {
#     principals {
#       type = "AWS"
#       identifiers = [
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/iac",
#       ]
#     }

#     actions = [
#       "s3:*"
#     ]

#     resources = [
#       module.bucket.s3_bucket_arn,
#       "${module.bucket.s3_bucket_arn}/*"
#     ]
#   }

#   statement {
#     principals {
#       type = "AWS"
#       identifiers = [
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/iac",
#         module.irsa.iam_role_arn,
#         module.codebuild.codebuild_role_arn,
#         module.codepipeline.codepipeline_role_arn
#       ]
#     }

#     actions = [
#       "s3:GetObject",
#       "s3:GetObjectAcl",
#       "s3:GetObjectVersion",
#       "s3:GetBucketVersioning",
#       "s3:PutObjectAcl",
#       "s3:PutObject",
#       "s3:DeleteObject",
#       "s3:DeleteObjectVersion",
#     ]

#     resources = [
#       module.bucket.s3_bucket_arn,
#       "${module.bucket.s3_bucket_arn}/*"
#     ]
#   }
# }

# # Codebuild policy
# data "aws_iam_policy_document" "codebuild_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]

#     resources = ["*"]
#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "ec2:CreateNetworkInterface",
#       "ec2:DescribeDhcpOptions",
#       "ec2:DescribeNetworkInterfaces",
#       "ec2:DeleteNetworkInterface",
#       "ec2:DescribeSubnets",
#       "ec2:DescribeSecurityGroups",
#       "ec2:DescribeVpcs",
#     ]

#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["ec2:CreateNetworkInterfacePermission"]
#     resources = ["arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*"]

#     condition {
#       test     = "StringEquals"
#       variable = "ec2:Subnet"
#       values   = data.terraform_remote_state.all.outputs.main_node_subnet_arns
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "ec2:AuthorizedService"
#       values   = ["codebuild.amazonaws.com"]
#     }
#   }

#   statement {
#     effect  = "Allow"
#     actions = ["s3:*"]
#     resources = [
#       module.bucket.s3_bucket_arn,
#       "${module.bucket.s3_bucket_arn}/*"
#     ]
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:BatchGetImage",
#       "ecr:CompleteLayerUpload",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:InitiateLayerUpload",
#       "ecr:PutImage",
#       "ecr:UploadLayerPart",
#       "ecr:SetRepositoryPolicy",
#       "ecr:DescribeImages",
#       "ecr:DescribeRepositories",
#       "ecr:ListImages",
#       "ecr:DeleteRepositoryPolicy",
#       "ecr:GetRepositoryPolicy",
#       "ecr:GetAuthorizationToken"
#     ]
#     resources = [
#       "*",
#     ]
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "ssm:GetParameters",
#     ]
#     resources = [
#       "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.unit}/${var.env}/ops/ssm/*",
#     ]
#   }
# }

# # Codepipeline policy
# data "aws_iam_policy_document" "codepipeline_policy" {
#   statement {
#     sid    = "AllowUserCodepipelineToUseCodeStarConnections"
#     effect = "Allow"

#     actions = [
#       "codestar-connections:UseConnection"
#     ]

#     resources = [
#       module.codestar_connection.connection_arn
#     ]
#   }

#   statement {
#     sid    = "AllowUserCodepipelineToStartCodeBuild"
#     effect = "Allow"

#     actions = [
#       "codebuild:BatchGetBuilds",
#       "codebuild:StartBuild"
#     ]

#     resources = [
#       module.codebuild.codebuild_arn
#     ]
#   }
# }

# # Service irsa policy
# data "aws_iam_policy_document" "irsa_policy" {
#   # Allow access to DynamoDB
#   statement {
#     effect = "Allow"

#     actions = [
#       "dynamodb:BatchGetItem",
#       "dynamodb:BatchWriteItem",
#       "dynamodb:ConditionCheckItem",
#       "dynamodb:DeleteItem",
#       "dynamodb:GetItem",
#       "dynamodb:GetRecords",
#       "dynamodb:PutItem",
#       "dynamodb:Query",
#       "dynamodb:Scan",
#       "dynamodb:UpdateItem"
#     ]

#     resources = [
#       "*",
#     ]
#   }
#   # Allow access to KMS
#   statement {
#     effect = "Allow"

#     actions = [
#       "kms:Decrypt",
#       "kms:Encrypt",
#       "kms:GenerateDataKey*",
#       "kms:ReEncrypt*",
#       "kms:Sign",
#       "kms:Verify"
#     ]

#     resources = [
#       data.terraform_remote_state.all.outputs.main_key_arn,
#     ]
#   }
# }
