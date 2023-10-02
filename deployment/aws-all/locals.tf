resource "random_password" "secret" {
  length           = 64
  override_special = "!#$%&*@"
  min_lower        = 10
  min_upper        = 10
  min_numeric      = 10
  min_special      = 5
}

locals {
  region = var.region
  tags = {
    GithubRepo = var.github_repo
    GithubOrg  = var.github_owner
  }
  # name   = "ex-${replace(basename(path.cwd), "_", "-")}"

  vpc_cidr     = "10.0.0.0/16"
  rfc6598_cidr = "100.64.0.0/16"
  azs          = slice(data.aws_availability_zones.available.names, 0, length(data.aws_availability_zones.available.names))
  # KMS Locals
  kms_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "sec"
    Feature = "kms"
    Sub     = "main"
  }
  kms_naming_standard = "${local.kms_standard.Unit}-${local.kms_standard.Env}-${local.kms_standard.Code}-${local.kms_standard.Feature}-${local.kms_standard.Sub}"
  # S3 Locals
  s3_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "stor"
    Feature = "s3"
    Sub     = "tfstate"
  }
  s3_naming_standard = "${local.s3_standard.Unit}-${local.s3_standard.Env}-${local.s3_standard.Code}-${local.s3_standard.Feature}-${local.s3_standard.Sub}"
  # Keypair Locals
  keypair_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "sec"
    Feature = "keypair"
    Sub     = "main"
  }
  # SSM Locals
  ssm_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "ops"
    Feature = "ssm"
    Sub     = "iac"
  }
  ssm_naming_standard = "/${local.ssm_standard.Unit}/${local.ssm_standard.Env}/${local.ssm_standard.Code}/${local.ssm_standard.Feature}/${local.ssm_standard.Sub}"
  secret_map          = { for k, v in data.aws_kms_secrets.secrets : k => v.plaintext[k] }
  secrets_merge = merge(
    local.secret_map,
    {
      "ssh_key_main"  = module.keypair_main.private_key_openssh
      "github_secret" = random_password.secret.result
    }
  )
  configs = {
    for k, v in var.configs :
    k => {
      value           = v
      type            = "String"
      tier            = "Standard"
      allowed_pattern = "[a-z0-9_]+"
    }
  }
  secrets = {
    for k, v in local.secrets_merge :
    k => {
      value  = v
      type   = "SecureString"
      tier   = "Standard"
      key_id = module.kms_main.key_id
    }
  }
  parameters = merge(local.configs, local.secrets)
  # VPC Locals
  vpc_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "net"
    Feature = "vpc"
    Sub     = "main"
  }
  vpc_naming_standard = "${local.vpc_standard.Unit}-${local.vpc_standard.Env}-${local.vpc_standard.Code}-${local.vpc_standard.Feature}-${local.vpc_standard.Sub}"
  # Route53 Locals
  route53_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "net"
    Feature = "route53"
    Sub     = "main"
  }
  route53_domain_name = "${var.unit}.blast.co.id"
  # ACM Locals
  acm_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "sec"
    Feature = "acm"
    Sub     = "main"
  }
  acm_naming_standard = "${local.acm_standard.Unit}-${local.acm_standard.Env}-${local.acm_standard.Code}-${local.acm_standard.Feature}-${local.acm_standard.Sub}"
  # VPC CNI Locals
  vpc_cni_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "iam"
    Feature = "role"
    Sub     = "vpc-cni-irsa"
  }
  vpc_cni_naming_standard = "${local.vpc_cni_standard.Unit}-${local.vpc_cni_standard.Env}-${local.vpc_cni_standard.Code}-${local.vpc_cni_standard.Feature}-${local.vpc_cni_standard.Sub}"
  # EKS Locals
  eks_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "con"
    Feature = "eks"
    Sub     = "main"
  }
  eks_naming_standard = "${local.eks_standard.Unit}-${local.eks_standard.Env}-${local.eks_standard.Code}-${local.eks_standard.Feature}-${local.eks_standard.Sub}"
  cluster_version     = "1.27"
  # eks_workload_type       = "ec2"
  # Karpenter Locals
  karpenter_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "k8s"
    Feature = "addon"
    Sub     = "karpenter"
  }
  # AWS ALB Ingress Controller Locals
  alb_controller_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "k8s"
    Feature = "addon"
    Sub     = "alb-controller"
  }
  # External DNS Locals
  external_dns_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "k8s"
    Feature = "addon"
    Sub     = "external-dns"
  }
  # ArgoCD Locals
  argocd_standard = {
    Unit    = var.unit
    Env     = var.env
    Code    = "k8s"
    Feature = "addon"
    Sub     = "argocd"
  }
}
