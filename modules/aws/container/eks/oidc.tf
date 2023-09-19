# Create OIDC Provider for EKS Cluster

# Get information about TLS certificate for OIDC Provider
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# Create OIDC Provider
resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = [data.tls_certificate.oidc.certificates.0.sha1_fingerprint]
  url             = data.tls_certificate.oidc.url
}

# Create external OIDC Provider
resource "aws_eks_identity_provider_config" "external_oidc" {
  count        = var.oidc_provider != null ? 1 : 0
  cluster_name = aws_eks_cluster.cluster.name

  dynamic "oidc" {
    for_each = var.oidc_provider != null ? [var.oidc_provider] : []
    content {
      client_id                     = oidc.value.client_id
      identity_provider_config_name = oidc.value.identity_provider_config_name
      issuer_url                    = oidc.value.issuer_url
      groups_claim                  = oidc.value.groups_claim
      groups_prefix                 = oidc.value.groups_prefix
      required_claims               = oidc.required_claims
      username_claim                = oidc.value.username_claim
      username_prefix               = oidc.value.username_prefix
    }
  }
}