# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
  default     = "us-west-2"
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

variable "code" {
  type        = string
  description = "Service domain code."
}

variable "feature" {
  type        = list(string)
  description = "Service feature."
}


# VPC arguments
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "vpc_enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC."
  default     = false
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  default     = false
}

variable "vpc_instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC."
  default     = "default"
}

# NAT arguments
variable "nat_total_eip" {
  type        = number
  description = "Total elastic IP of NAT gateway."
}