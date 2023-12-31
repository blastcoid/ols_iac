# Create a Google Compute VPC
# This VPC will serve as the primary network for other resources.

locals {
  naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}"
}
resource "google_compute_network" "vpc" {
  name                    = "${local.naming_standard}-main"
  auto_create_subnetworks = var.auto_create_subnetworks # Disable default subnets creation for more granular control
}

# Create a Google Compute Subnetwork within the VPC
# This subnetwork will be used by GKE and other resources within the VPC.
# CIDR ranges are determined based on the environment.
resource "google_compute_subnetwork" "subnet" {
  name = "${local.naming_standard}-subnet"
  ip_cidr_range = var.standard.env == "dev" ? var.ip_cidr_range.dev : (
    var.standard.env == "stg" ? var.ip_cidr_range.stg : var.ip_cidr_range.prd
  )
  network = google_compute_network.vpc.self_link # Link to the VPC created above

  dynamic "secondary_ip_range" {
    for_each = var.standard.env == "dev" ? var.secondary_ip_range.dev : (
      var.standard.env == "stg" ? var.secondary_ip_range.stg : var.secondary_ip_range.prd
    )
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

# Create a Google Compute Router
# This router will manage traffic routing and connect the VPC to external networks.
resource "google_compute_router" "router" {
  name    = "${local.naming_standard}-router"
  region  = var.region
  network = google_compute_network.vpc.self_link
}

# Create a Google Compute External IP Address if NAT IP allocation is set to MANUAL_ONLY
# This IP will be used by the Cloud NAT for outbound traffic.
resource "google_compute_address" "address" {
  count  = var.nat_ip_allocate_option == "MANUAL_ONLY" ? 3 : 0
  name   = "${local.naming_standard}-address-${count.index}"
  region = google_compute_subnetwork.subnet.region
}

# Create a Google Compute NAT
# Cloud NAT allows VM instances without external IPs to access the internet.
# It uses either auto-allocated or manually specified IPs based on the configuration.
resource "google_compute_router_nat" "nat" {
  name                               = "${local.naming_standard}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  nat_ips                            = var.nat_ip_allocate_option == "MANUAL_ONLY" ? google_compute_address.address.*.self_link : [] # set to empty list if NAT IP allocation is set to AUTO_ONLY or DISABLED
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  # Define subnetworks that will use this Cloud NAT if "LIST_OF_SUBNETWORKS" is specified
  dynamic "subnetwork" {
    for_each = var.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS" ? var.subnetworks : []
    content {
      name                    = subnetwork.value.name
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat
    }
  }
}

# Create default firewall rules

resource "google_compute_firewall" "firewall" {
  for_each = var.vpc_firewall_rules
  name     = "${local.naming_standard}-allow-${each.key}"
  network  = google_compute_network.vpc.self_link

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  source_ranges = each.key == "internal" && var.standard.env == "dev" ? each.value.source_ranges.dev : (
    each.key == "internal" && var.standard.env == "stg" ? each.value.source_ranges.stg : (
      each.key == "internal" && var.standard.env == "prd" ? each.value.source_ranges.prd : each.value.source_ranges.any
    )
  )
  priority = each.value.priority
}
