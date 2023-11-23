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
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    bcrypt = {
      source  = "viktorradnai/bcrypt"
      version = "0.1.2"
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

provider "aws" {
  region  = "us-east-1"
  profile = "${var.unit}-${var.env}"
  alias   = "virginia"
  dynamic "assume_role" {
    for_each = local.is_ec2_environment ? [] : [1]
    content {
      role_arn = "arn:aws:iam::124456474132:role/iac"
    }
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cloud.outputs.main_eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cloud.outputs.main_eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Create Helm provider
provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.cloud.outputs.main_eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.cloud.outputs.main_eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
  registry {
    url      = "oci://public.ecr.aws"
    username = data.aws_ecrpublic_authorization_token.token.user_name
    password = data.aws_ecrpublic_authorization_token.token.password
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = data.terraform_remote_state.cloud.outputs.main_eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cloud.outputs.main_eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}
