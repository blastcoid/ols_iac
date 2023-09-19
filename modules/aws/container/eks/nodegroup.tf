locals {
  node_config = var.standard.env == "dev" ? { spot = var.node_config["spot"] } : var.node_config
}

resource "aws_launch_template" "launch_template" {
  for_each = var.node_config

  name_prefix   = "${local.naming_standard}-${each.key}"
  description   = "EKS Node Template for ${local.naming_standard}-${each.key}"
  instance_type = each.value.instance_type[var.standard.env]
  key_name      = each.value.key_name
  # image_id      = data.aws_ssm_parameter.bottlerocket.value
  dynamic "iam_instance_profile" {
    for_each = lookup(each.value, "iam_instance_profile", null) != null ? [each.value.iam_instance_profile] : []
    content {
      name = iam_instance_profile.value.name
    }
  }
  # # Managed Node Group currently does not support instance_market_options
  # dynamic "instance_market_options" {
  #   for_each = lookup(each.value, "instance_market_options", null) != null ? [each.value.instance_market_options] : []
  #   content {
  #     market_type = instance_market_options.value.market_type
  #     dynamic "spot_options" {
  #       for_each = lookup(instance_market_options.value, "spot_options", null) != null ? [instance_market_options.value.spot_options] : []
  #       content {
  #         block_duration_minutes         = spot_options.value.block_duration_minutes
  #         instance_interruption_behavior = spot_options.value.instance_interruption_behavior
  #         max_price                      = spot_options.value.max_price == null ? data.aws_ec2_spot_price.get.spot_price : instance_market_options.value.max_price
  #         spot_instance_type             = spot_options.value.spot_instance_type
  #         valid_until                    = spot_options.value.valid_until
  #       }
  #     }
  #   }
  # }

  dynamic "block_device_mappings" {
    for_each = lookup(each.value, "block_device_mappings", null) != null ? [each.value.block_device_mappings] : []
    content {
      device_name = block_device_mappings.value.device_name
      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", null) != null ? [block_device_mappings.value.ebs] : []
        content {
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
          delete_on_termination = ebs.value.delete_on_termination
          encrypted             = ebs.value.encrypted
          kms_key_id            = ebs.value.kms_key_id
        }
      }
    }
  }

  vpc_security_group_ids = [aws_security_group.ng.id]
  user_data = base64encode(<<USERDATA
[settings.kubernetes]
"cluster-name" = "${aws_eks_cluster.cluster.name}"
"api-server" = "${aws_eks_cluster.cluster.endpoint}"
"cluster-certificate" = "${aws_eks_cluster.cluster.certificate_authority.0.data}"
"cluster-dns-ip" = "172.20.0.10"
"max-pods" = ${tonumber(data.external.get_max_pods[each.key].result.max_pods)}
[settings.kubernetes.node-labels]
"eks.amazonaws.com/nodegroup-image" = "${data.aws_ssm_parameter.bottlerocket.value}"
"eks.amazonaws.com/capacityType" = "${each.value.capacity_type}"
"eks.amazonaws.com/nodegroup" = "${local.naming_standard}-${each.key}"
USERDATA
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name"               = "${local.naming_standard}-${each.key}"
      "Unit"               = var.standard.unit
      "Env"                = var.standard.env
      "Code"               = var.standard.code
      "Feature"            = var.standard.feature
      "eks:cluster-name"   = aws_eks_cluster.cluster.name
      "eks:nodegroup-name" = "${local.naming_standard}-${each.key}"
    }
  }

  tags = {
    "Name"               = "${local.naming_standard}-${each.key}"
    "Unit"               = var.standard.unit
    "Env"                = var.standard.env
    "Code"               = var.standard.code
    "Feature"            = var.standard.feature
    "eks:cluster-name"   = aws_eks_cluster.cluster.name
    "eks:nodegroup-name" = "${local.naming_standard}-${each.key}"
  }
}

resource "aws_eks_node_group" "ng" {
  for_each        = var.node_config
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${local.naming_standard}-${each.key}"
  # version         = aws_eks_cluster.cluster.version
  # release_version = nonsensitive(data.aws_ssm_parameter.bottlerocket.value)
  node_role_arn = aws_iam_role.node_role.arn
  subnet_ids    = each.value.subnet_ids
  capacity_type = each.value.capacity_type
  ami_type      = each.value.ami_type

  launch_template {
    id      = aws_launch_template.launch_template[each.key].id
    version = aws_launch_template.launch_template[each.key].latest_version
  }

  dynamic "scaling_config" {
    for_each = lookup(each.value, "scaling_config", null) != null ? [each.value.scaling_config] : []
    content {
      desired_size = scaling_config.value.desired_size
      max_size     = scaling_config.value.max_size
      min_size     = scaling_config.value.min_size
    }
  }

  dynamic "update_config" {
    for_each = lookup(each.value, "update_config", null) != null ? [each.value.update_config] : []
    content {
      max_unavailable            = update_config.value.max_unavailable
      max_unavailable_percentage = update_config.value.max_unavailable_percentage
    }
  }

  tags = {
    "Name"    = "${local.naming_standard}-${each.key}"
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = var.standard.sub
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
  timeouts {
    create = "10m"
    update = "10m"
    delete = "15m"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy_readonly,
    aws_kms_grant.grant_node,
    aws_eks_addon.addons_before_nodegroup
  ]
}