# Local Variables
# ---------------
# Define a naming standard for VPC and related resources.
# The naming standard concatenates 'unit', 'env', 'code', 'feature', and 'sub' variables.
locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
}

# AWS Availability Zones Data Source
# ----------------------------------
# Fetch the available Availability Zones in the region to provision subnets.
data "aws_availability_zones" "az" {
  state = "available"
}

# AWS VPC Resource
# ----------------
# This section sets up an AWS VPC with specified configurations like CIDR block, DNS settings, and instance tenancy.
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  instance_tenancy     = var.vpc_instance_tenancy
  tags = {
    "Name"    = local.naming_standard
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
  }
}

# AWS VPC CIDR Block Association Resource
# ---------------------------------------
# Associate the additional VPC CIDR block with the VPC.
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id      = aws_vpc.vpc.id
  cidr_block  = var.vpc_app_cidr
}

# AWS Node Subnets Resource
# ------------------------
# Provision multiple subnets in the fetched Availability Zones for Node workload.
resource "aws_subnet" "node" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  tags = {
    "Name"    = "${local.naming_standard}-subnet-node-${split("-", element(data.aws_availability_zones.az.names, count.index))[2]}"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Zones"   = element(data.aws_availability_zones.az.names, count.index)
  }
}

# AWS App Subnets Resource
# ------------------------
# Provision multiple subnets in the fetched Availability Zones for App pods workload.
resource "aws_subnet" "app" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block, 3, count.index)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  tags = {
    "Name"    = "${local.naming_standard}-subnet-app-${split("-", element(data.aws_availability_zones.az.names, count.index))[2]}"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Zones"   = element(data.aws_availability_zones.az.names, count.index)
  }
}

# AWS Data Subnets Resource
# -------------------------
# Provision multiple subnets in the fetched Availability Zones for data workload.
resource "aws_subnet" "data" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = length(data.aws_availability_zones.az.names) <= 2 ? cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + 4) : cidrsubnet(aws_vpc.vpc.cidr_block, 5, count.index + 24)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  tags = {
    "Name"    = "${local.naming_standard}-subnet-data-${split("-", element(data.aws_availability_zones.az.names, count.index))[2]}"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Zones"   = element(data.aws_availability_zones.az.names, count.index)
  }
}

# AWS Public Subnets Resource
# ---------------------------
# Provision multiple subnets in the fetched Availability Zones for DMZ tier.
resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = length(data.aws_availability_zones.az.names) <= 2 ? cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + 6) : cidrsubnet(aws_vpc.vpc.cidr_block, 5, count.index + 7)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  tags = {
    "Name"    = "${local.naming_standard}-subnet-public-${split("-", element(data.aws_availability_zones.az.names, count.index))[2]}"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Zones"   = element(data.aws_availability_zones.az.names, count.index)
  }
}
