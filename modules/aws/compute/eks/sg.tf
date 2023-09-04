## Create cluster security group

resource "aws_security_group" "cluster" {
  name        = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}-sg"
  description = "Security group for ${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
  vpc_id      = var.vpc_id

  ## Create foreach loop for ingress and egress rules
  dynamic "ingress" {
    for_each = length(var.eks_cluster_ingress_rules_cidr_blocks) > 0 ? var.eks_cluster_ingress_rules_cidr_blocks : []
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = length(var.eks_cluster_egress_rules_cidr_blocks) > 0 ? var.eks_cluster_egress_rules_cidr_blocks : []
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}-sg"
  }
}

resource "aws_security_group" "ng" {
  name        = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}-sg"
  description = "Security group for ${var.unit}-${var.env}-${var.code}-${var.feature[1]}"
  vpc_id      = var.vpc_id
  dynamic "ingress" {
    for_each = length(var.eks_node_ingress_rules_cidr_blocks) > 0 ? var.eks_node_ingress_rules_cidr_blocks : []
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = length(var.eks_node_egress_rules_cidr_blocks) > 0 ? var.eks_node_egress_rules_cidr_blocks : []
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}-sg"
  }
}
