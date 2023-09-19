resource "aws_eks_addon" "addons_before_nodegroup" {
  for_each                    = var.cluster_addons_before_nodegroup
  addon_name                  = each.key
  cluster_name                = aws_eks_cluster.cluster.name
  addon_version               = lookup(each.value, "version", data.aws_eks_addon_version.latest_before_nodegroup[each.key].version)
  resolve_conflicts_on_create = lookup(each.value, "resolve_conflicts_on_create", "NONE")
  resolve_conflicts_on_update = lookup(each.value, "resolve_conflicts_on_update", "NONE")
  configuration_values        = lookup(each.value, "configuration_values", null)
  service_account_role_arn    = lookup(each.value, "service_account_role_arn", null)
  tags = merge(
    var.standard,
    {
      "Name" = "${local.naming_standard}-${each.key}"
    }
  )
  timeouts {
    create = "10m"
    update = "10m"
    delete = "15m"
  }
}

# install aws eks plugins
resource "aws_eks_addon" "addons_after_nodegroup" {
  for_each                    = var.cluster_addons_after_nodegroup
  addon_name                  = each.key
  cluster_name                = aws_eks_cluster.cluster.name
  addon_version               = lookup(each.value, "version", data.aws_eks_addon_version.latest_after_nodegroup[each.key].version)
  resolve_conflicts_on_create = lookup(each.value, "resolve_conflicts_on_create", "NONE")
  resolve_conflicts_on_update = lookup(each.value, "resolve_conflicts_on_update", "NONE")
  configuration_values        = lookup(each.value, "configuration_values", null)
  service_account_role_arn    = lookup(each.value, "service_account_role_arn", null)
  tags = merge(
    var.standard,
    {
      "Name" = "${local.naming_standard}-${each.key}"
    }
  )
  timeouts {
    create = "10m"
    update = "10m"
    delete = "15m"
  }

  depends_on = [aws_eks_node_group.ng]
}
