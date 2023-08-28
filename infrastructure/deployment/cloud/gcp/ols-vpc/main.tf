# Configure the backend for Terraform state storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "vpc/ols-dev-vpc-network"
  }
}

# Deploy the VPC using the VPC module
module "vpc" {
  source  = "../../modules/network/vpc"
  region  = "asia-southeast2"
  unit    = "ols"
  env     = "dev"
  code    = "vpc"
  feature = ["network", "subnet", "router", "address", "nat", "allow"]
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
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
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
