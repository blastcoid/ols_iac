# # Check whether the current environment is running on EC2 or not
# data "external" "is_running_on_ec2" {
#   program = ["bash", "-c", "curl -s -m 1 http://169.254.169.254/latest/meta-data/instance-id &>/dev/null && echo '{\"on_ec2\": \"true\"}' || echo '{\"on_ec2\": \"false\"}'"]
# }

# # if the current environment is running on EC2 then use instance profile to access AWS resources
# # otherwise assume the iac role
# locals {
#   is_ec2_environment = data.external.is_running_on_ec2.result["on_ec2"] != "true" ? true : false
# }

terraform {
  required_version = ">= 1.5.7"
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
    github = {
      source  = "integrations/github"
      version = "5.39.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "${var.unit}-${var.env}"
  assume_role {
    role_arn = "arn:aws:iam::124456474132:role/iac"
  }
  # dynamic "assume_role" {
  #   for_each = local.is_ec2_environment ? [] : [1]
  #   content {
  #     role_arn = "arn:aws:iam::124456474132:role/iac"
  #   }
  # }
}

# # Terraform backend configuration
# terraform {
#   backend "s3" {
#     bucket  = "ols-mstr-stor-s3-tfstate"
#     key     = "aws/services/ols-svc-genai.tfstate"
#     region  = "us-west-1"
#     profile = "ols-mstr"
#   }
# }

provider "kubernetes" {
  config_path = "~/.kube/config"
  experiments {
    manifest_resource = true
  }
}

# create helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubectl" {
  apply_retry_count = 5
  config_path       = "~/.kube/config"
}
