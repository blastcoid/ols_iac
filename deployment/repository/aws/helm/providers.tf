# if the current environment is running on EC2 then use instance profile to access AWS resources
# otherwise assume the iac role

data "external" "is_running_on_ec2" {
  program = ["bash", "-c", "curl -s -m 1 http://169.254.169.254/latest/meta-data/instance-id &>/dev/null && echo '{\"on_ec2\": \"true\"}' || echo '{\"on_ec2\": \"false\"}'"]
}

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
    github = {
      source  = "integrations/github"
      version = "5.36.0"
    }
  }
}

# Create AWS provider
provider "aws" {
  region  = var.region
  profile = "${var.unit}-${var.env}"
  dynamic "assume_role" {
    for_each = local.is_ec2_environment ? [] : [1]
    content {
      role_arn = "arn:aws:iam::124456474132:role/iac"
    }
  }
}

data "terraform_remote_state" "eks_main" {
  backend = "s3"

  config = {
    bucket = "${var.unit}-${var.env}-stor-s3-tfstate"
    key    = "aws/cloud/${var.unit}-${var.env}-cloud-resources.tfstate"
    region = var.region
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks_main.outputs.main_eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_main.outputs.main_eks_cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks_main.outputs.main_eks_cluster_name]
  }
}

