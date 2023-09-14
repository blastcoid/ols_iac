# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
  default     = "us-west-1"
}

variable "unit" {
  type        = string
  description = "Business unit code."
  default     = "ols"
}

variable "env" {
  type        = string
  description = "Stage environment where the infrastructure will be deployed."
}

# Config & Secrets
variable "configs" {
  type        = map(string)
  description = "A map containing config variables for resources."
}

variable "secrets_ciphertext" {
  type        = map(string)
  description = "The encrypted secret value."
  # sensitive   = true
}

# VPC naming standard
variable "code" {
  type        = list(string)
  description = "Service domain code."
  default     = ["storage", "security", "network", "compute"]
}

# Features
variable "s3_feature" {
  type        = list(string)
  description = "S3 Feature names"
  default     = ["iac-tfstate"]
}

variable "kms_feature" {
  type        = list(string)
  description = "KMS Feature names"
  default     = ["kms-main"]
}

variable "vpc_feature" {
  type        = list(string)
  description = "VPC Feature names"
  default     = ["vpc-main", "vpc-subnet", "vpc-igw", "vpc-nat", "vpc-rt"]
}

variable "route53_feature" {
  type        = list(string)
  description = "Route53 Feature names"
  default     = ["route53-blast"]
}

variable "ec2_feature" {
  type        = list(string)
  description = "EC2 Feature names"
  default     = ["ec2-keypair", "ec2-atlantis"]
}

variable "eks_feature" {
  type        = list(string)
  description = "EKS Feature names"
  default     = ["eks-main", "eks-ng"]
}
