# Node Route Table Resource
# -------------------------
# Create a route table for Node subnets in the VPC.
# The number of route tables is conditional based on the environment.
# Each route table has a default route via a NAT Gateway.
resource "aws_route_table" "node_rt" {
  count  = var.standard.env != "mstr" && var.standard.env != "dev" ? length(aws_subnet.node) : 1
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.standard.env != "mstr" && var.standard.env != "dev" ? element(aws_nat_gateway.nat.*.id, count.index) : aws_nat_gateway.nat.0.id
  }

  tags = {
    "Name"       = "${local.naming_standard}-node-rt-${split("-", element(data.aws_availability_zones.az.names, count.index))[2]}"
    "Unit"       = var.standard.unit
    "Env"        = var.standard.env
    "Code"       = var.standard.code
    "Feature"    = var.standard.feature
  }
}

# Node Route Table Association
# ----------------------------
# Associate each Node subnet with its corresponding route table.
resource "aws_route_table_association" "node_rta" {
  count          = length(aws_subnet.node)
  subnet_id      = element(aws_subnet.node.*.id, count.index)
  route_table_id = element(aws_route_table.node_rt.*.id, count.index)
}

# App Route Table Resource
# ------------------------
# Create a route table for Application subnets in the VPC.
# The number of route tables is conditional based on the environment.
# Each route table has a default route via a NAT Gateway.
resource "aws_route_table" "app_rt" {
  count  = var.standard.env != "mstr" && var.standard.env != "dev" ? length(aws_subnet.app) : 1
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.standard.env != "mstr" && var.standard.env != "dev" ? element(aws_nat_gateway.nat.*.id, count.index) : aws_nat_gateway.nat.0.id
  }

  tags = {
    "Name"       = "${local.naming_standard}-app-rt-${split("-", element(data.aws_availability_zones.az.names, count.index))[2]}"
    "Unit"       = var.standard.unit
    "Env"        = var.standard.env
    "Code"       = var.standard.code
    "Feature"    = var.standard.feature
  }
}

# App Route Table Association
# ---------------------------
# Associate each Application subnet with its corresponding route table.
resource "aws_route_table_association" "app_rta" {
  count          = length(aws_subnet.app)
  subnet_id      = element(aws_subnet.app.*.id, count.index)
  route_table_id = element(aws_route_table.app_rt.*.id, count.index)
}

# Data Route Table Resource
# -------------------------
# Create a route table for Data subnets in the VPC.
# The number of route tables is conditional based on the environment.
# Each route table has a default route via a NAT Gateway.
resource "aws_route_table" "data_rt" {
  count  = var.standard.env != "mstr" && var.standard.env != "dev" ? length(aws_subnet.app) : 1
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.standard.env != "mstr" && var.standard.env != "dev" ? element(aws_nat_gateway.nat.*.id, count.index) : aws_nat_gateway.nat.0.id
  }

  tags = {
    "Name"       = "${local.naming_standard}-data-rt-${split("-", element(data.aws_availability_zones.az.names, count.index))[2]}"
    "Unit"       = var.standard.unit
    "Env"        = var.standard.env
    "Code"       = var.standard.code
    "Feature"    = var.standard.feature
  }
}

# Data Route Table Association
# ----------------------------
# Associate each Data subnet with its corresponding route table.
resource "aws_route_table_association" "data_rta" {
  count          = length(aws_subnet.data)
  subnet_id      = element(aws_subnet.data.*.id, count.index)
  route_table_id = element(aws_route_table.data_rt.*.id, count.index)
}

# Public Route Table Resource
# ---------------------------
# Create a public route table in the VPC.
# This route table has a default route via an Internet Gateway.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name"       = "${local.naming_standard}-public-rt"
    "Unit"       = var.standard.unit
    "Env"        = var.standard.env
    "Code"       = var.standard.code
    "Feature"    = var.standard.feature
  }
}

# Public Route Table Association
# ------------------------------
# Associate each Public subnet with the public route table.
resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}
