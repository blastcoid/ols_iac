# if the current environment is running on EC2 then use instance profile to access AWS resources
# otherwise assume the iac role
locals {
  is_ec2_environment = data.external.is_running_on_ec2.result["on_ec2"] == "true" ? true : false
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

# Create AWS provider
provider "aws" {
  region  = local.region
  profile = "${var.unit}-${var.env}"
  dynamic "assume_role" {
    for_each = local.is_ec2_environment ? [] : [1]
    content {
      role_arn = "arn:aws:iam::124456474132:role/iac"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks_main.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_main.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}