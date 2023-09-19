# AWS Settings
variable "region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS region where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "A map containing standard naming convention variables for resources."
}

# VPC arguments
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "vpc_app_cidr" {
  type        = string
  description = "The CIDR block for the application subnet within the VPC."
}

variable "vpc_enable_dns_support" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable DNS support in the VPC."
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}

variable "vpc_instance_tenancy" {
  type        = string
  default     = "default"
  description = "A tenancy option for instances launched into the VPC (default, dedicated)."
}

# Subnet arguments
variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

# NAT arguments
variable "nat_total_eip" {
  type        = number
  description = "The total number of Elastic IPs for the NAT Gateway."
}
