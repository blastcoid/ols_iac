resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name"       = "${var.unit}-${var.env}-${var.code}-${var.feature[2]}}"
    "Unit"       = var.unit
    "Env"        = var.env
    "Code"       = var.code
    "Feature"    = var.feature[2]
  }
}

resource "aws_eip" "eip" {
  count = var.env != "dev" ? var.nat_total_eip : 1
  domain   = "vpc"

  tags = {
    "Name"       = "${var.unit}-${var.env}-${var.code}-${var.feature[3]}-${count.index}"
    "Unit"       = var.unit
    "Env"        = var.env
    "Code"       = var.code
    "Feature"    = var.feature[3]
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.env != "dev" ? length(aws_subnet.public) : 1
  allocation_id = var.env != "dev" ? element(aws_eip.eip.*.id, count.index) : aws_eip.eip.0.id
  subnet_id     = var.env != "dev" ? element(aws_subnet.public.*.id, count.index) : aws_subnet.public.0.id

  tags = {
    "Name"       = "${var.unit}-${var.env}-${var.code}-${var.feature[3]}-${element(data.aws_availability_zones.az.names, count.index)}"
    "Unit"       = var.unit
    "Env"        = var.env
    "Code"       = var.code
    "Feature"    = var.feature[3]
    "Zones"      = element(data.aws_availability_zones.az.names, count.index)
  }
}