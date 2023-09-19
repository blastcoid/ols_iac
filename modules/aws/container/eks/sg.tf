# Create additional cluster security group
# resource "aws_security_group" "cluster" {
#   name        = "${local.naming_standard}-sg"
#   description = "Security group for ${local.naming_standard}"
#   vpc_id      = var.vpc_id
#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     "Name"    = "${local.naming_standard}-sg"
#     "Unit"    = var.standard.unit
#     "Env"     = var.standard.env
#     "Code"    = var.standard.code
#     "Feature" = var.standard.feature
#     "Sub"     = var.standard.sub
#   }
# }

# Create Nodegroup security group
resource "aws_security_group" "ng" {
  name        = "${local.naming_standard}-ng-sg"
  description = "Security group for ${local.naming_standard}"
  vpc_id      = var.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name"    = "${local.naming_standard}-ng-sg"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = var.standard.sub
  }

  timeouts {
    create = "5m"
    delete = "5m"
  }
}

# Create ALB security group
resource "aws_security_group" "alb" {
  name        = "${local.naming_standard}-alb-sg"
  description = "Security group for ${local.naming_standard}"
  vpc_id      = var.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name"    = "${local.naming_standard}-alb-sg"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = var.standard.sub
  }

  timeouts {
    create = "5m"
    delete = "5m"
  }
}

# Create cluster security group rules

resource "aws_security_group_rule" "cluster_rules" {
  count                    = length(var.eks_cluster_sg_ingress_rules)
  type                     = "ingress"
  from_port                = var.eks_cluster_sg_ingress_rules[count.index].from_port
  to_port                  = var.eks_cluster_sg_ingress_rules[count.index].to_port
  protocol                 = var.eks_cluster_sg_ingress_rules[count.index].protocol
  security_group_id        = var.eks_cluster_sg_ingress_rules[count.index].security_group_id == null ? aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id : var.eks_cluster_sg_ingress_rules[count.index].security_group_id
  cidr_blocks              = var.eks_cluster_sg_ingress_rules[count.index].cidr_blocks
  source_security_group_id = var.eks_cluster_sg_ingress_rules[count.index].source_security_group_id == "node" ? aws_security_group.ng.id : var.eks_cluster_sg_ingress_rules[count.index].source_security_group_id
  self                     = var.eks_cluster_sg_ingress_rules[count.index].cidr_blocks == null && var.eks_cluster_sg_ingress_rules[count.index].source_security_group_id == null ? true : null
  timeouts {
    create = "5m"
  }
}

# Create node group security group rules
resource "aws_security_group_rule" "ng_rules" {
  count                    = length(var.eks_ng_sg_ingress_rules)
  type                     = "ingress"
  from_port                = var.eks_ng_sg_ingress_rules[count.index].from_port
  to_port                  = var.eks_ng_sg_ingress_rules[count.index].to_port
  protocol                 = var.eks_ng_sg_ingress_rules[count.index].protocol
  security_group_id        = var.eks_ng_sg_ingress_rules[count.index].security_group_id == null ? aws_security_group.ng.id : var.eks_ng_sg_ingress_rules[count.index].security_group_id
  cidr_blocks              = var.eks_ng_sg_ingress_rules[count.index].cidr_blocks
  source_security_group_id = var.eks_ng_sg_ingress_rules[count.index].source_security_group_id == "cluster" ? aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id : var.eks_ng_sg_ingress_rules[count.index].source_security_group_id
  self                     = var.eks_ng_sg_ingress_rules[count.index].cidr_blocks == null && var.eks_ng_sg_ingress_rules[count.index].source_security_group_id == null ? true : null
  timeouts {
    create = "5m"
  }
}

# Create ALB security group rules
resource "aws_security_group_rule" "alb_rules" {
  count                    = length(var.eks_alb_sg_ingress_rules)
  type                     = "ingress"
  from_port                = var.eks_alb_sg_ingress_rules[count.index].from_port
  to_port                  = var.eks_alb_sg_ingress_rules[count.index].to_port
  protocol                 = var.eks_alb_sg_ingress_rules[count.index].protocol
  security_group_id        = var.eks_alb_sg_ingress_rules[count.index].security_group_id == null ? aws_security_group.alb.id : var.eks_alb_sg_ingress_rules[count.index].security_group_id
  cidr_blocks              = var.eks_alb_sg_ingress_rules[count.index].cidr_blocks
  source_security_group_id = var.eks_alb_sg_ingress_rules[count.index].source_security_group_id == "node" ? aws_security_group.ng.id : var.eks_alb_sg_ingress_rules[count.index].source_security_group_id
  self                     = var.eks_alb_sg_ingress_rules[count.index].cidr_blocks == null && var.eks_alb_sg_ingress_rules[count.index].source_security_group_id == null ? true : null
  timeouts {
    create = "5m"
  }
}
