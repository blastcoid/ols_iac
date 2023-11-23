# if the current environment is running on EC2 then use instance profile to access AWS resources
# otherwise assume the iac role
locals {
  is_ec2_environment = data.external.is_running_on_ec2.result["on_ec2"] == "true" ? true : false
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

# Create terraform state
terraform {
  backend "s3" {
    bucket  = "ols-mstr-stor-s3-tfstate"
    key     = "aws/all/ols-mstr-all-deployment.tfstate"
    region  = "us-west-1"
    profile = "ols-mstr"
  }
}

# Create Kubernetes provider
provider "kubernetes" {
  host                   = module.eks_main.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_main.cluster_kubeconfig_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command     = "aws"
  #   args = [
  #     "eks",
  #     "get-token",
  #     "--cluster-name",
  #     module.eks_main.cluster_name
  #   ]
  # }
}

# Create Helm provider
provider "helm" {
  kubernetes {
    host                   = module.eks_main.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_main.cluster_kubeconfig_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    # exec {
    #   api_version = "client.authentication.k8s.io/v1beta1"
    #   command     = "aws"
    #   args = [
    #     "eks",
    #     "get-token",
    #     "--cluster-name",
    #     module.eks_main.cluster_name
    #   ]
    # }
  }
}

