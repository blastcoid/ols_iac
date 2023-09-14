data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.cluster.version}/amazon-linux-2/recommended/release_version"
}

data "aws_ami" "eks_latest_ami" {
  most_recent = true

  filter {
    name   = "Name"
    values = ["amazon-eks-node-${var.k8s_version}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-id"
    values = ["602401143452"] # AWS EKS AMI Owner ID
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ec2_spot_price" "get" {
  instance_type     = var.node_config["spot"].instance_type[var.env]
  availability_zone = "${var.region}a"

  filter {
    name   = "product-description"
    values = ["Linux/UNIX"]
  }
}

# locals {
#   node_config = var.env == "dev" ? { spot = var.node_config["spot"] } : var.node_config
# }

# resource "aws_launch_template" "template" {
#   for_each = var.node_config

#   name_prefix = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}-${each.key}"
#   description = "EKS Node Template for ${var.unit}-${var.env}-${var.code}-${var.feature[1]}-${each.key}"
#   instance_type = var.env == "dev" ? each.value.instance_type["dev"] : (
#     var.env == "stg" ? each.value.instance_type["stg"] : each.value.instance_type["prd"]
#   )
#   key_name = each.value.key_name
#   image_id = data.aws_ami.eks_latest_ami.id
#   dynamic "iam_instance_profile" {
#     for_each = lookup(each.value, "iam_instance_profile", null) != null ? [each.value.iam_instance_profile] : []
#     content {
#       name = iam_instance_profile.value.name
#     }
#   }

#   dynamic "instance_market_options" {
#     for_each = lookup(each.value, "instance_market_options", null) != null ? [each.value.instance_market_options] : []
#     content {
#       market_type = instance_market_options.value.market_type
#       dynamic "spot_options" {
#         for_each = lookup(instance_market_options.value, "spot_options", null) != null ? [instance_market_options.value.spot_options] : []
#         content {
#           block_duration_minutes         = spot_options.value.block_duration_minutes
#           instance_interruption_behavior = spot_options.value.instance_interruption_behavior
#           max_price                      = spot_options.value.max_price == null ? data.aws_ec2_spot_price.get.spot_price : instance_market_options.value.max_price
#           spot_instance_type             = spot_options.value.spot_instance_type
#           valid_until                    = spot_options.value.valid_until
#         }
#       }
#     }
#   }

#   dynamic "block_device_mappings" {
#     for_each = lookup(each.value, "block_device_mappings", null) != null ? [each.value.block_device_mappings] : []
#     content {
#       device_name = block_device_mappings.value.device_name
#       dynamic "ebs" {
#         for_each = lookup(block_device_mappings.value, "ebs", null) != null ? [block_device_mappings.value.ebs] : []
#         content {
#           volume_size           = ebs.value.volume_size
#           volume_type           = ebs.value.volume_type
#           delete_on_termination = ebs.value.delete_on_termination
#           encrypted             = ebs.value.encrypted
#           kms_key_id            = ebs.value.kms_key_id
#         }
#       }
#     }
#   }

#   vpc_security_group_ids = [aws_security_group.ng.id]
#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       "Name"    = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}-main"
#       "Unit"    = var.unit
#       "Env"     = var.env
#       "Code"    = var.code
#       "Feature" = var.feature[1]
#     }
#   }
# }

# resource "aws_eks_node_group" "ng" {
#   for_each        = var.node_config
#   cluster_name    = aws_eks_cluster.cluster.name
#   node_group_name = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}-${each.key}"
#   # version         = aws_eks_cluster.cluster.version
#   # release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
#   node_role_arn = aws_iam_role.node_role.arn
#   subnet_ids    = var.subnet_ids
#   launch_template {
#     id      = aws_launch_template.template[each.key].id
#     version = aws_launch_template.template[each.key].latest_version
#   }

#   dynamic "scaling_config" {
#     for_each = lookup(each.value, "scaling_config", null) != null ? [each.value.scaling_config] : []
#     content {
#       desired_size = scaling_config.value.desired_size
#       max_size     = scaling_config.value.max_size
#       min_size     = scaling_config.value.min_size
#     }
#   }

#   dynamic "update_config" {
#     for_each = lookup(each.value, "update_config", null) != null ? [each.value.update_config] : []
#     content {
#       max_unavailable            = update_config.value.max_unavailable
#       max_unavailable_percentage = update_config.value.max_unavailable_percentage
#     }
#   }


#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_node_policy,
#     aws_iam_role_policy_attachment.eks_cni_policy,
#     aws_iam_role_policy_attachment.eks_ecr_policy_readonly,
#     aws_kms_grant.grant,
#   ]

#   tags = {
#     "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}" = each.key
#   }

#   lifecycle {
#     ignore_changes = [scaling_config[0].desired_size]
#   }
# }
