# locals {
#   create_aws_auth_configmap               = length(var.node_config) == 0 && length(var.fargate_selectors) == 0
#   update_aws_auth_configmap               = !local.create_aws_auth_configmap
#   aws_auth_node_iam_role_arns_non_windows = null
#   node_role_arns                          = [
#     aws.iam_role.node_role.arn
#   ]
#   aws_auth_configmap_data = {
#     mapRoles = yamlencode(
#       compact(
#         concat(
#           # Managed Nodegroup
#           [ for role_arn in local.node_iam_role_arns : 
#             {
#               rolearn  = role_arn
#               username = "system:node:{{EC2PrivateDNSName}}"
#               groups = [
#                 "system:bootstrappers",
#                 "system:nodes",
#               ]
#             }
#           ],
#           # Fargate profile
#           [
#             {
#               rolearn  = aws_iam_role.fargate_role.arn
#               username = "system:node:{{SessionName}}"
#               groups = [
#                 "system:bootstrappers",
#                 "system:nodes",
#                 "system:node-proxier",
#               ]
#             }
#           ],
#           var.aws_auth_roles
#         )
#       )
#     )
#     mapUsers    = yamlencode(var.aws_auth_users)
#     mapAccounts = yamlencode(var.aws_auth_accounts)
#   }
# }

# resource "kubernetes_config_map_v1" "aws_auth" {
#   count      = local.create_aws_auth_configmap ? 1 : 0
#   depends_on = [data.http.wait_for_cluster]

#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     "mapRoles"    = yamlencode(local.merged_map_roles)
#     "mapUsers"    = yamlencode(var.map_users)
#     "mapAccounts" = yamlencode(var.map_accounts)
#   }
#   lifecycle {
#     # We are ignoring the data here since we will manage it with the resource below
#     # This is only intended to be used in scenarios where the configmap does not exist
#     ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
#   }
# }


# resource "kubernetes_config_map_v1_data" "aws_auth" {
#   count      = local.update_aws_auth_configmap ? 1 : 0
#   depends_on = [data.http.wait_for_cluster]

#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     "mapRoles"    = yamlencode(local.merged_map_roles)
#     "mapUsers"    = yamlencode(var.map_users)
#     "mapAccounts" = yamlencode(var.map_accounts)
#   }

#   force = true
# }
