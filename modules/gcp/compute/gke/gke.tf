# Get the current project id
data "google_project" "current" {}

locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}"
}

# Create a GKE cluster with 2 node pools
resource "google_container_cluster" "cluster" {
  # Define the cluster name using variables
  name             = "${local.naming_standard}-${var.standard.sub}"
  # Set the location based on environment and autopilot settings
  location         = var.standard.env == "dev" ? "${var.region}-a" : var.region
  # Enable autopilot if the variable is set, otherwise set to null
  enable_autopilot = !var.enable_autopilot ? null : true
  dynamic "cluster_autoscaling" {
    # Configure cluster autoscaling if autopilot is not enabled
    for_each = !var.enable_autopilot ? [var.cluster_autoscaling] : []
    content {
      enabled = cluster_autoscaling.value.enabled
      # Define resource limits for autoscaling
      dynamic "resource_limits" {
        for_each = cluster_autoscaling.value.enabled ? cluster_autoscaling.value.resource_limits : {}
        content {
          resource_type = resource_limits.key
          minimum       = resource_limits.value.minimum
          maximum       = resource_limits.value.maximum
        }
      }
    }
  }
  # Remove the default node pool if not in autopilot mode
  remove_default_node_pool = !var.enable_autopilot ? true : null
  initial_node_count       = 1

  # Configure master authentication with client certificate
  master_auth {
    client_certificate_config {
      issue_client_certificate = var.issue_client_certificate
    }
  }

  # Configure private cluster settings based on variables
  dynamic "private_cluster_config" {
    for_each = var.private_cluster_config[var.standard.env].enable_private_endpoint || var.private_cluster_config[var.standard.env].enable_private_nodes ? [lookup(var.private_cluster_config, var.standard.env)] : []
    content {
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes
      master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block
    }
  }
  # Set binary authorization mode
  dynamic "binary_authorization" {
    for_each = var.binary_authorization != {} || var.binary_authorization.evaluation_mode != null ? [var.binary_authorization] : []
    content {
      evaluation_mode = binary_authorization.value.evaluation_mode
    }
  }

  # Configure network policy if not in autopilot mode and enabled
  dynamic "network_policy" {
    for_each = !var.enable_autopilot && var.network_policy.enabled ? [var.network_policy] : []
    content {
      enabled  = network_policy.value.enabled
      provider = network_policy.value.provider
    }
  }
  # Set datapath provider (Dataplane V2), incompatible with network policy
  datapath_provider = !var.network_policy.enabled ? var.datapath_provider : null
  # Define authorized networks for master access
  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config != {} ? [var.master_authorized_networks_config] : []
    content {
      # Define authorized networks
      dynamic "cidr_blocks" {
        for_each = [master_authorized_networks_config.value.cidr_blocks]
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
      # Enable access from GCP public IP ranges
      gcp_public_cidrs_access_enabled = master_authorized_networks_config.value.gcp_public_cidrs_access_enabled
    }
  }

  # Define IP allocation policy for cluster and services
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }
  # Set network and subnetwork links
  network    = var.vpc_self_link
  subnetwork = var.subnet_self_link
  # Configure DNS settings based on environment
  dynamic "dns_config" {
    for_each = var.dns_config[var.standard.env].cluster_dns != null ? [lookup(var.dns_config, var.standard.env)] : []
    content {
      cluster_dns        = dns_config.value.cluster_dns
      cluster_dns_scope  = dns_config.value.cluster_dns_scope
      cluster_dns_domain = dns_config.value.cluster_dns_domain
    }
  }
  # Configure workload identity settings
  workload_identity_config {
    workload_pool = "${data.google_project.current.project_id}.svc.id.goog"
  }
  # Define resource labels for the cluster
  resource_labels = {
    name    = "${local.naming_standard}-${var.standard.sub}"
    unit    = var.standard.unit
    env     = var.standard.env
    code    = var.standard.code
    feature = var.standard.feature
    sub     = var.standard.sub
  }
}

# Define local variable for node configuration based on environment
locals {
  node_config = var.standard.env == "dev" ? { spot = var.node_config["spot"] } : var.node_config
}

# Create an on-demand node pool
resource "google_container_node_pool" "nodepool" {
  for_each   = !var.enable_autopilot ? local.node_config : {}
  name       = each.key
  location   = var.standard.env == "dev" && !var.enable_autopilot ? "${var.region}-a" : var.region
  cluster    = google_container_cluster.cluster.name
  node_count = var.standard.env == "dev" ? 2 : each.value.node_count

  # Define node configuration settings based on environment and variables
  node_config {
    machine_type = var.standard.env == "dev" ? each.value.machine_type["dev"] : (
      var.standard.env == "stg" ? each.value.machine_type["stg"] : each.value.machine_type["prd"]
    )
    disk_size_gb    = each.value.disk_size_gb
    disk_type       = var.standard.env == "dev" ? each.value.disk_type[0] : each.value.disk_type[1]
    service_account = each.value.service_account
    oauth_scopes    = each.value.oauth_scopes
    tags            = each.value.tags
    # Configure shielded instance settings if secure boot is enabled
    dynamic "shielded_instance_config" {
      for_each = lookup(each.value, "shielded_instance_config", null) != null ? [1] : []
      content {
        enable_secure_boot          = each.value.shielded_instance_config.enable_secure_boot
        enable_integrity_monitoring = each.value.shielded_instance_config.enable_integrity_monitoring
      }
    }
    # Configure workload metadata config
    dynamic "workload_metadata_config" {
      for_each = lookup(each.value, "workload_metadata_config", null) != null ? [1] : []
      content {
        mode = each.value.workload_metadata_config.mode
      }
    }
    # Define node labels
    labels = {
      name          = "${local.naming_standard}-${var.standard.sub}-nodepool-${each.key}"
      business_unit = var.standard.unit
      environment   = var.standard.env
      code          = var.standard.code
      feature       = var.standard.feature
      sub           = var.standard.sub
      type          = each.key
    }
  }

  # Configure node management settings for auto repair and upgrade
  dynamic "management" {
    for_each = var.node_management.auto_repair || var.node_management.auto_upgrade ? [1] : []
    content {
      auto_repair  = var.node_management.auto_repair
      auto_upgrade = var.node_management.auto_upgrade
    }
  }

  # Configure autoscaling settings for spot instances
  dynamic "autoscaling" {
    for_each = var.autoscaling[each.key] != {} ? [lookup(var.autoscaling, each.key)] : []
    content {
      min_node_count  = autoscaling.value.min_node_count
      max_node_count  = autoscaling.value.max_node_count
      location_policy = autoscaling.value.location_policy
    }
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}

# # Workaround for a known bug (https://github.com/hashicorp/terraform-provider-kubernetes/issues/1424)
# data "google_client_config" "current" {}

# provider "kubernetes" {
#   host                   = "https://${google_container_cluster.cluster.endpoint}"
#   token                  = data.google_client_config.current.access_token
#   cluster_ca_certificate = base64decode(google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
# }

# # Define cluster role binding for client cluster admin
# resource "kubernetes_cluster_role_binding" "client_cluster_admin" {
#   metadata {
#     annotations = {}
#     labels      = {}
#     name        = "client-cluster-admin"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   # Define subjects for the role binding
#   subject {
#     kind      = "User"
#     name      = "client"
#     api_group = "rbac.authorization.k8s.io"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = "default"
#     namespace = "kube-system"
#   }
#   subject {
#     kind      = "Group"
#     name      = "system:masters"
#     api_group = "rbac.authorization.k8s.io"
#   }
# }
