# Configure the backend for Terraform state storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/network/ols-dev-network-vpc-main"
  }
}

# Deploy the VPC using the VPC module
module "vpc_main" {
  source                  = "../../../../modules/gcp/network/vpc"
  region                  = "asia-southeast2"
  project_id              = "${var.unit}-platform-${var.env}"
  env                     = var.env
  vpc_name                = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
  auto_create_subnetworks = false
  subnet_name             = "${var.unit}-${var.env}-${var.code}-${var.feature[1]}"
  ip_cidr_range = {
    dev = "10.0.0.0/16"
    stg = "10.1.0.0/16"
    prd = "10.2.0.0/16"
  }
  secondary_ip_range = {
    dev = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "172.16.0.0/16"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "172.17.0.0/16"
      }
    ]
    stg = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "172.18.0.0/16"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "172.19.0.0/16"
      }
    ]
    prd = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "172.20.0.0/16"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "172.21.0.0/16"
      }
    ]
  }
  router_name                        = "${var.unit}-${var.env}-${var.code}-${var.feature[2]}"
  address_name                       = "${var.unit}-${var.env}-${var.code}-${var.feature[3]}"
  nat_name                           = "${var.unit}-${var.env}-${var.code}-${var.feature[4]}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  firewall_name                      = "${var.unit}-${var.env}-${var.code}-${var.feature[5]}"
  vpc_firewall_rules = {
    icmp = {
      name        = "allow-icmp"
      description = "Allow ICMP from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      source_ranges = {
        any = ["0.0.0.0/0"]
      }
      priority = 65534
    }
    internal = {
      name        = "allow-internal"
      description = "Allow internal traffic on the network."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
          ports    = []
        }
      ]
      # source ranges based on the environment
      source_ranges = {
        dev = ["10.0.0.0/16"]
        stg = ["10.1.0.0/16"]
        prd = ["10.2.0.0/16"]
      }
      priority = 65534
    }
    ssh = {
      name        = "allow-ssh"
      description = "Allow SSH from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
      source_ranges = {
        any = ["0.0.0.0/0"]
      }
      priority = 65534
    }
    rdp = {
      name        = "allow-rdp"
      description = "Allow RDP from any source to any destination."
      direction   = "INGRESS"
      allow = [
        {
          protocol = "tcp"
          ports    = ["3389"]
        }
      ]
      source_ranges = {
        any = ["0.0.0.0/0"]
      }
      priority = 65534
    }
  }
}
