locals {
  naming_standard = "${var.standard.unit}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
  # DNS
  dns_private_visibility_config = var.zone_visibility == "private" ? [var.private_visibility_config] : []
}

resource "google_dns_managed_zone" "zone" {
  name          = local.naming_standard
  dns_name      = var.zone_dns_name
  description   = "Cloud DNS for ${var.zone_dns_name}"
  force_destroy = var.zone_force_destroy
  visibility    = var.zone_visibility
  dynamic "private_visibility_config" {
    for_each = local.dns_private_visibility_config
    content {
      dynamic "networks" {
        for_each = private_visibility_config.value.networks != null ? [private_visibility_config.value.networks] : []
        content {
          network_url = networks.value.network_url
        }
      }
      dynamic "gke_clusters" {
        for_each = private_visibility_config.value.gke_clusters != null ? [private_visibility_config.value.gke_clusters] : []
        content {
          gke_cluster_name = gke_clusters.value.gke_cluster_name
        }
      }
    }
  }
}
