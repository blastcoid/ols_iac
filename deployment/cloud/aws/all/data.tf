# Check whether the current environment is running on EC2 or not
data "external" "is_running_on_ec2" {
  program = ["bash", "-c", "curl -s -m 1 http://169.254.169.254/latest/meta-data/instance-id &>/dev/null && echo '{\"on_ec2\": \"true\"}' || echo '{\"on_ec2\": \"false\"}'"]
}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}

# Get availability zones
data "aws_availability_zones" "available" {}

# KMS
## Get KMS secrets values
data "aws_kms_secrets" "secrets" {
  for_each = var.secrets_ciphertext
  secret {
    name    = each.key
    payload = each.value
  }
}

# Query the latest EKS AMI
data "aws_ssm_parameter" "bottlerocket" {
  name = "/aws/service/bottlerocket/aws-k8s-${local.cluster_version}/arm64/latest/image_id"
}
data "aws_ami" "bottlerocket" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${local.cluster_version}-aarch64-*"]
  }
}

# # EKS
# ## Get EKS cluster auth
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_main.cluster_name
}