# KMS module
module "kms_main" {
  source = "../../modules/aws/security/kms"
  region = var.region

  standard = {
    unit    = "ols"
    env     = "mstr"
    code    = "sec"
    feature = "kms"
    sub     = "main"
  }
  kms_key_usage                = "ENCRYPT_DECRYPT"
  kms_enable_key_rotation      = true
  kms_deletion_window_in_days  = 7
  kms_is_enabled               = true
  kms_customer_master_key_spec = "SYMMETRIC_DEFAULT"
  kms_policy = {
    Id      = "${var.unit}-${var.env}-sec-kms-main-policy"
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow access for Key Administrators"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/imam.arief.rhmn@gmail.com",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/iac"
          ]
        }
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow access for user iac to generate data key for terraform state"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/iac",
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  }
}

# Bucket Policy

# S3 module
module "s3_bucket_tfstate" {
  source     = "../../modules/aws/storage/s3"
  region     = var.region
  account_id = data.aws_caller_identity.current.account_id
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "stor"
    feature = "s3"
    sub     = "tfstate"
    name    = null
  }
  force_destroy           = true
  object_lock_enabled     = false
  bucket_acl              = "private"
  bucket_object_ownership = "BucketOwnerPreferred"
  bucket_policy           = data.aws_iam_policy_document.bucket_policy.json
  server_side_encryption = {
    sse_algorithm     = "aws:kms"
    kms_master_key_id = module.kms_main.key_arn
  }
}

module "keypair_main" {
  source = "../../modules/aws/compute/keypair"
  region = var.region
  standard = {
    unit    = "ols"
    env     = "mstr"
    code    = "com"
    feature = "keypair"
    sub     = "main"
  }
  algorithm = "RSA"
  rsa_bits  = 2048
}

locals {
  secret_map = {for k, v in data.aws_kms_secrets.secrets : k => v.plaintext[k]}
  secrets = merge(
    local.secret_map,
    { "ssh_key_main" = module.keypair_main.private_key }
  )
}

module "ssm_params" {
  source = "../../modules/aws/devops/ssm"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "ops"
    feature = "ssm"
    sub     = "iac"
    name    = null
  }
  tier    = "Standard"
  configs = var.configs
  secrets = local.secrets
}

# module "route53_main" {
#   source = "../../modules/aws/network/route53"
#   standard = {
#     unit    = "ols"
#     env     = "mstr"
#     code    = "net"
#     feature = "route53"
#     sub     = "main"
#   }
#   route53_zone_name     = "${var.unit}.blast.co.id"
#   route53_force_destroy = true
# }

module "vpc_main" {
  source = "../../modules/aws/network/vpc"
  region = var.region
  standard = {
    unit    = "ols"
    env     = "mstr"
    code    = "net"
    feature = "vpc"
    sub     = "main"
  }
  vpc_cidr                 = "10.0.0.0/16"
  vpc_app_cidr             = "100.64.0.0/16"
  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true
  nat_total_eip            = 1
}

# module "eks_main" {
#   source                  = "../../modules/aws/compute/eks"
#   region                  = var.region
#   standard = {
#     unit    = "ols"
#     env     = "mstr"
#     code    = "net"
#     feature = "vpc"
#     sub     = "main"
#   }
#   unit                    = var.unit
#   env                     = var.env
#   code                    = var.code[3]
#   feature                 = var.eks_feature
#   k8s_version             = "1.27"
#   vpc_id                  = module.vpc_main.vpc_id
#   subnet_ids              = flatten(module.vpc_main.*.app_id)
#   endpoint_private_access = true
#   endpoint_public_access  = true
#   public_access_cidrs     = ["182.253.194.32/28"]
#   key_arn                 = module.kms_main.key_arn
#   eks_cluster_ingress_rules_cidr_blocks = [
#     # Allow access to the cluster's Kubernetes API server endpoint from the VPC CIDR block
#     {
#       from_port   = 6443
#       to_port     = 6443
#       protocol    = "tcp"
#       cidr_blocks = [module.vpc_main.vpc_cidr_block]
#     },
#     # Allow incoming traffic from the worker node security group on port 10250 (Kubelet)
#     {
#       from_port   = 10250
#       to_port     = 10250
#       protocol    = "tcp"
#       cidr_blocks = [module.vpc_main.vpc_cidr_block]
#     },
#     # Allow incoming traffic from the worker node security group on port 10255 (Read-only Kubelet)
#     {
#       from_port   = 10255
#       to_port     = 10255
#       protocol    = "tcp"
#       cidr_blocks = [module.vpc_main.vpc_cidr_block]
#     },
#   ]
#   eks_cluster_egress_rules_cidr_blocks = [
#     # Allow outgoing traffic to the internet
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#   ]
#   node_config = {
#     # ondemand = {
#     #   instance_type = {
#     #     dev = "t3.medium"
#     #     stg = "c5.large"
#     #     prd = "c5.xlarge"
#     #   }
#     #   instance_market_options = null
#     #   scaling_config = {
#     #     desired_size = 0
#     #     max_size     = 1
#     #     min_size     = 0
#     #   }
#     #   key_name             = module.keypair_main.key_name
#     #   iam_instance_profile = null
#     #   block_device_mappings = {
#     #     # root_block_device
#     #     device_name = "/dev/xvda"
#     #     ebs = {
#     #       volume_size           = 20
#     #       volume_type           = "standard"
#     #       delete_on_termination = true
#     #       encrypted             = false
#     #       kms_key_id            = null # module.kms_main.key_arn
#     #     }
#     #   }
#     #   subnet_ids = flatten(module.vpc_main.*.app_id)
#     # },
#     spot = {
#       instance_type = {
#         dev = "t3.medium"
#         stg = "c5.large"
#         prd = "c5.xlarge"
#       }
#       instance_market_options = {
#         market_type = "spot"
#         spot_options = {
#           block_duration_minutes = null
#           instance_interruption_behavior = "terminate"
#           max_price = null
#           spot_instance_type = "one-time"
#           valid_until = null
#         }
#       }
#       scaling_config = {
#         desired_size = 0
#         max_size     = 4
#         min_size     = 2
#       }
#       key_name             = module.keypair_main.key_name
#       iam_instance_profile = null
#       block_device_mappings = {
#         # root_block_device
#         device_name = "/dev/xvda"
#         ebs = {
#           volume_size           = 20
#           volume_type           = "standard"
#           delete_on_termination = true
#           encrypted             = true
#           kms_key_id            = module.kms_main.key_arn
#         }
#       }
#       subnet_ids = flatten(module.vpc_main.*.app_id)
#     }
#   }
#   eks_node_ingress_rules_cidr_blocks = [
#     # Allow access to the cluster's Kubernetes API server endpoint from the VPC CIDR block
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       cidr_blocks = [module.vpc_main.vpc_cidr_block, "182.253.194.32/28"]
#     },
#   ]
#   eks_node_egress_rules_cidr_blocks = [
#     # Allow outgoing traffic to the internet
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     },
#   ]
# }
