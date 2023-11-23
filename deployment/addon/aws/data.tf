# Data terraform state
# Check whether the current environment is running on EC2 or not
data "external" "is_running_on_ec2" {
  program = ["bash", "-c", "curl -s -m 1 http://169.254.169.254/latest/meta-data/instance-id &>/dev/null && echo '{\"on_ec2\": \"true\"}' || echo '{\"on_ec2\": \"false\"}'"]
}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}

# Get availibility zones
data "aws_availability_zones" "available" {}

data "terraform_remote_state" "cloud" {
  backend = "s3"

  config = {
    bucket  = "${var.unit}-${var.env}-stor-s3-tfstate"
    key     = "aws/cloud/${var.unit}-${var.env}-cloud-resources.tfstate"
    region  = var.region
    profile = "${var.unit}-${var.env}"
  }
}

# EKS
## Get EKS cluster auth
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.cloud.outputs.main_eks_cluster_name
}

# Get ECR public token from us-east-1
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}
