# KMS module
module "kms_main" {
  source = "../../modules/aws/security/kms"
  region = var.region

  standard = {
    unit    = var.unit
    env     = var.env
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
    unit    = var.unit
    env     = var.env
    code    = "com"
    feature = "keypair"
    sub     = "main"
  }
  algorithm = "RSA"
  rsa_bits  = 2048
}

locals {
  secret_map = { for k, v in data.aws_kms_secrets.secrets : k => v.plaintext[k] }
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

module "route53_main" {
  source = "../../modules/aws/network/route53"
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "net"
    feature = "route53"
    sub     = "main"
  }
  route53_zone_name     = "${var.unit}.blast.co.id"
  route53_force_destroy = true
}

module "vpc_main" {
  source = "../../modules/aws/network/vpc"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "net"
    feature = "vpc"
    sub     = "main"
  }
  vpc_cidr                 = "10.0.0.0/16"
  vpc_app_cidr             = "100.64.0.0/16" # RFC 6598
  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true
  cluster_name             = "${var.unit}-${var.env}-con-eks-main"
  nat_total_eip            = 1
}

module "eks_main" {
  source = "../../modules/aws/container/eks"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "con"
    feature = "eks"
    sub     = "main"
  }
  account_id      = data.aws_caller_identity.current.account_id
  cluster_version = "1.27"
  vpc_id          = module.vpc_main.vpc_id
  vpc_config = {
    subnet_ids              = module.vpc_main.node_id
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs = concat(
      [for subnet in module.vpc_main.nat_public_ips : "${subnet}/32"],
      ["182.253.194.0/24"]
    )
  }
  key_arn = module.kms_main.key_arn
  kms_grant_operations = [
    "CreateGrant",
    "Decrypt",
    "DescribeKey",
    "Encrypt",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "ReEncryptFrom",
    "ReEncryptTo",
  ]
  eks_cluster_sg_ingress_rules = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = "node"
      description              = "Allow incoming traffic from the worker node security group on port 443 (HTTPS)"
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      cidr_blocks = [module.vpc_main.vpc_cidr_block]
      description = "Allow access to the cluster's Kubernetes API server endpoint from the VPC CIDR block"
    },
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow incoming traffic from internet on all ports"
    }
  ]
  eks_ng_sg_ingress_rules = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = "cluster"
      description              = "Allow incoming traffic from the cluster control plane on port 10250 (Kubelet)"
    },
    {
      from_port                = 1025
      to_port                  = 65535
      protocol                 = "tcp"
      source_security_group_id = "cluster"
      description              = "Allow incoming traffic from the cluster control plane on port 10250 (Kubelet)"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [module.vpc_main.vpc_cidr_block]
      description = "Allow SSH from VPC CIDR block"
    },
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      self        = true
      description = "Allow node to communicate with each other"
    },
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow incoming traffic from internet on all ports"
    }
  ]
  eks_alb_sg_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow incoming traffic from internet on port 80 (HTTP)"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow incoming traffic from internet on port 443 (HTTPS)"
    },
    # allow incoming traffic from worker node
    {
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      source_security_group_id = "node"
      description              = "Allow incoming traffic from the worker node security group on all ports"
    }
  ]
  wait_for_cluster_timeout = "300" # seconds
  cluster_addons_before_nodegroup = {
    vpc-cni = {
      version                     = "v1.15.0-eksbuild.2"
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      # Enable custom network configuration for VPC CNI
      configuration_values = jsonencode({
        eniConfig = {
          create = true,
          region = var.region,
          subnets = {
            "${data.aws_availability_zones.az.names[0]}" = {
              id             = module.vpc_main.app_id[0]
              securityGroups = [module.eks_main.cluster_sg_id]
            },
            "${data.aws_availability_zones.az.names[1]}" = {
              id             = module.vpc_main.app_id[1]
              securityGroups = [module.eks_main.cluster_sg_id]
            }
          }
        },
        env = {
          AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true",
          ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
        }
      })
      service_account_role_arn = module.eks_main.vpc_cni_role_arn
    }
  }
  cluster_addons_after_nodegroup = {
    kube-proxy = {
      version                     = "v1.27.4-eksbuild.2"
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      version                     = "v1.10.1-eksbuild.4"
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values = jsonencode({
        replicaCount = 2
        resources = {
          limits = {
            cpu    = "100m"
            memory = "150Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "150Mi"
          }
        }
      })
    }
  }
  node_config = {
    # ondemand = {
    #   instance_type = {
    #     mstr = "t4g.medium"
    #     dev  = "t4g.medium"
    #     stg  = "c6g.large"
    #     prd  = "c6g.xlarge"
    #   }
    #   capacity_type = "ON_DEMAND"
    #   scaling_config = {
    #     desired_size = 0
    #     max_size     = 1
    #     min_size     = 0
    #   }
    #   key_name             = module.keypair_main.key_name
    #   iam_instance_profile = null
    #   block_device_mappings = {
    #     # root_block_device
    #     device_name = "/dev/xvda"
    #     ebs = {
    #       volume_size           = 20
    #       volume_type           = "standard"
    #       delete_on_termination = true
    #       encrypted             = true
    #       kms_key_id            = module.kms_main.key_arn
    #     }
    #   }
    #   subnet_ids = flatten(module.vpc_main.*.node_id)
    # },
    spot = {
      instance_type = {
        mstr = "t4g.medium"
        dev  = "t4g.medium"
        stg  = "c6g.large"
        prd  = "c6g.xlarge"
      }
      capacity_type = "SPOT"
      ami_type      = "BOTTLEROCKET_ARM_64"
      disk_size     = 20
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 2
      }
      key_name             = module.keypair_main.key_name
      iam_instance_profile = null
      block_device_mappings = {
        # root_block_device
        device_name = "/dev/xvdb"
        ebs = {
          volume_size           = 20
          volume_type           = "gp3"
          delete_on_termination = true
          encrypted             = true
          kms_key_id            = module.kms_main.key_arn
        }
      }
      subnet_ids = flatten(module.vpc_main.*.node_id)
    }
  }
  # fargate_selectors = [
  #   {
  #     namespace = "dev"
  #     labels = {
  #       "eks.amazonaws.com/compute-type" = "fargate"
  #       "eks.amazonaws.com/unit"         = "ols"
  #       "eks.amazonaws.com/env"          = "dev"
  #     }
  #   },
  #   {
  #     namespace = "stg"
  #     labels = {
  #       "eks.amazonaws.com/compute-type" = "fargate"
  #       "eks.amazonaws.com/unit"         = "ols"
  #       "eks.amazonaws.com/env"          = "stg"
  #     }
  #   },
  #   {
  #     namespace = "prd"
  #     labels = {
  #       "eks.amazonaws.com/compute-type" = "fargate"
  #       "eks.amazonaws.com/unit"         = "ols"
  #       "eks.amazonaws.com/env"          = "prd"
  #     }
  #   }
  # ]
}

module "external_dns" {
  source = "../../modules/cicd/helm"
  region = var.region
  standard = {
    unit    = var.unit
    env     = var.env
    code    = "cicd"
    feature = "helm"
    sub     = "external-dns"
  }
  cloud_provider         = "aws"
  repository             = "https://charts.bitnami.com/bitnami"
  chart                  = "external-dns"
  create_service_account = true
  iam_policy             = data.aws_iam_policy_document.externaldns_policy.json
  eks_oidc_arn           = module.eks_main.oidc_provider_arn
  eks_oidc_url           = module.eks_main.oidc_provider_url
  values                 = ["${file("helm/external-dns.yaml")}"]
  helm_sets = [
    {
      name  = "provider"
      value = "aws"
    },
    {
      name  = "aws.region"
      value = var.region
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "aws.zoneType"
      value = "public"
    }
  ]
  helm_sets_list = [
    {
      name  = "sources"
      value = ["service", "ingress"]
    }
  ]
  namespace        = "ingress"
  create_namespace = true
  depends_on = [
    module.eks_main
  ]
}
