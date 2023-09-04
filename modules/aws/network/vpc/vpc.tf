data "aws_availability_zones" "az" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  instance_tenancy     = var.vpc_instance_tenancy
  tags = {
    "Name"    = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
    "Env"     = var.env
    "Code"    = var.code
    "Feature" = var.feature[0]
  }
}


resource "aws_subnet" "app" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 2, count.index)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  tags = {
    "Name"    = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}-app-${element(data.aws_availability_zones.az.names, count.index)}"
    "Unit"    = var.unit
    "Env"     = var.env
    "Code"    = var.code
    "Feature" = var.feature[1]
    "Zones"   = element(data.aws_availability_zones.az.names, count.index)
  }
}

resource "aws_subnet" "data" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = length(data.aws_availability_zones.az.names) <= 2 ? cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + 4) : cidrsubnet(aws_vpc.vpc.cidr_block, 5, count.index + 24)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  tags = {
    "Name"    = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}-data-${element(data.aws_availability_zones.az.names, count.index)}"
    "Unit"    = var.unit
    "Env"     = var.env
    "Code"    = var.code
    "Feature" = var.feature[1]
    "Zones"   = element(data.aws_availability_zones.az.names, count.index)
  }
}

resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = length(data.aws_availability_zones.az.names) <= 2 ? cidrsubnet(aws_vpc.vpc.cidr_block, 3, count.index + 6) : cidrsubnet(aws_vpc.vpc.cidr_block, 5, count.index + 7)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)
  tags = {
    "Name"    = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}-public-${element(data.aws_availability_zones.az.names, count.index)}"
    "Unit"    = var.unit
    "Env"     = var.env
    "Code"    = var.code
    "Feature" = var.feature[1]
    "Zones"   = element(data.aws_availability_zones.az.names, count.index)
  }
}
