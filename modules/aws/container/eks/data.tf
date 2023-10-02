# Query the latest EKS AMI
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.cluster.version}/amazon-linux-2/recommended/release_version"
}

data "aws_ssm_parameter" "bottlerocket" {
  name = "/aws/service/bottlerocket/aws-k8s-${aws_eks_cluster.cluster.version}/arm64/latest/image_id"
}

# # Get the spot price for the instance type
# data "aws_ec2_spot_price" "get" {
#   instance_type     = var.node_config["spot"].instance_type[var.standard.env]
#   availability_zone = "${var.region}a"

#   filter {
#     name   = "product-description"
#     values = ["Linux/UNIX"]
#   }
# }

# Get the latest VPC CNI version
data "aws_eks_addon_version" "latest_before_nodegroup" {
  for_each           = var.cluster_addons_before_nodegroup
  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = each.value.most_recent
}

data "aws_eks_addon_version" "latest_after_nodegroup" {
  for_each           = var.cluster_addons_after_nodegroup
  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = each.value.most_recent
}

# Get oidc assume role policy

data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc.arn]
      type        = "Federated"
    }
  }
}

# Get the max pods for the instance type from max-pods-calculator.sh
data "external" "get_max_pods" {
  for_each = var.node_config
  program = var.cluster_addons_before_nodegroup["vpc-cni"].configuration_values != null ? [
    "bash", "-c", "${path.module}/max-pods-calculator.sh --instance-type ${each.value.instance_type[var.standard.env]} --cni-version ${substr(var.cluster_addons_before_nodegroup["vpc-cni"].version, 1, -1)} --cni-custom-networking-enabled | jq -R '{\"max_pods\": .}'"
    ] : [
    "bash", "-c", "${path.module}/max-pods-calculator.sh --instance-type ${each.value.instance_type[var.standard.env]} --cni-version ${substr(var.cluster_addons_before_nodegroup["vpc-cni"].version, 1, -1)} | jq -R '{\"max_pods\": .}'"
  ]
}

# Wait for the cluster to be ready
# data "http" "wait_for_cluster" {
#   url                = format("%s/healthz", aws_eks_cluster.cluster.endpoint)
#   ca_cert_pem        = base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
#   request_timeout_ms = var.wait_for_cluster_timeout
# }
