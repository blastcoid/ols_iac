# AWS Internet Gateway Resource
# -----------------------------
# Create an Internet Gateway and attach it to the VPC.
# The gateway is also tagged according to the naming standard.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name"    = "${local.naming_standard}-igw"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = "igw"
  }
}

# AWS Elastic IP Resource
# ------------------------
# Create Elastic IP resources based on the environment.
# The number of EIPs is controlled by the 'nat_total_eip' variable.
# These EIPs are tagged based on the naming standard.
resource "aws_eip" "eip" {
  count  = var.standard.env != "dev" && var.standard.env != "mstr" ? var.nat_total_eip : 1
  domain = "vpc"

  tags = {
    "Name"    = "${local.naming_standard}-eip-${count.index}"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = "eip"
  }
}

# AWS NAT Gateway Resource
# ------------------------
# Create NAT Gateways based on the environment and attach them to public subnets.
# The number of NAT Gateways corresponds to the number of public subnets.
# Each NAT Gateway is associated with an Elastic IP.
# These NAT Gateways are tagged based on the naming standard.
resource "aws_nat_gateway" "nat" {
  count         = var.standard.env != "dev" ? length(aws_subnet.public) : 1
  allocation_id = var.standard.env != "dev" ? element(aws_eip.eip.*.id, count.index) : aws_eip.eip.0.id
  subnet_id     = var.standard.env != "dev" ? element(aws_subnet.public.*.id, count.index) : aws_subnet.public.0.id

  tags = {
    "Name"    = "${local.naming_standard}-nat-${split("-", element(data.aws_availability_zones.az.names, count.index))[2]}"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = "nat"
    "zones"   = element(data.aws_availability_zones.az.names, count.index)
  }
}
