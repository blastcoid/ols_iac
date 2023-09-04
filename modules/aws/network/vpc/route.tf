resource "aws_route_table" "app_rt" {
  count  = var.env != "master" && var.env != "dev" ? length(aws_subnet.app) : 1
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.env != "master" && var.env != "dev" ? element(aws_nat_gateway.nat.*.id, count.index) : aws_nat_gateway.nat.0.id
  }

  tags = {
    "Name"       = "${var.unit}-${var.env}-${var.code}-${var.feature[4]}-app"
    "Unit"       = var.unit
    "Env"        = var.env
    "Code"       = var.code
    "Feature"    = var.feature[4]
  }
}

resource "aws_route_table_association" "app_rta" {
  count          = length(aws_subnet.app)
  subnet_id      = element(aws_subnet.app.*.id, count.index)
  route_table_id = element(aws_route_table.app_rt.*.id, count.index)
}

#Data Route Table
resource "aws_route_table" "data_rt" {
  count  = var.env != "master" && var.env != "dev" ? length(aws_subnet.app) : 1
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.env != "master" && var.env != "dev" ? element(aws_nat_gateway.nat.*.id, count.index) : aws_nat_gateway.nat.0.id
  }

  tags = {
    "Name"       = "${var.unit}-${var.env}-${var.code}-${var.feature[4]}-data"
    "Unit"       = var.unit
    "Env"        = var.env
    "Code"       = var.code
    "Feature"    = var.feature[4]
  }
}

resource "aws_route_table_association" "data_rta" {
  count          = length(aws_subnet.data)
  subnet_id      = element(aws_subnet.data.*.id, count.index)
  route_table_id = element(aws_route_table.data_rt.*.id, count.index)
}

#Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name"       = "${var.unit}-${var.env}-${var.code}-${var.feature[4]}-public"
    "Unit"       = var.unit
    "Env"        = var.env
    "Code"       = var.code
    "Feature"    = var.feature[4]
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}