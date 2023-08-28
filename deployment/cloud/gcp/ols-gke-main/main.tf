# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gkubernetes-engine/ols-dev-gkubernetes-engine-ols"
  }
}

data "google_service_account" "gcompute_engine_default_service_account" {
  account_id = "104314449368242098130"
}

data "terraform_remote_state" "vpc_ols_network" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "vpc/ols-dev-vpc-network"
  }
}

# create gke from modules gke
module "gkubernetes_engine" {
  # Naming standard
  source  = "../../modules/compute/gkubernetes-engine"
  region  = "asia-southeast2"
  unit    = "ols"
  env     = "dev"
  code    = "gkubernetes-engine"
  feature = "cluster"
  # cluster arguments
  issue_client_certificate      = false
  vpc_self_link                 = data.terraform_remote_state.vpc_ols_network.outputs.vpc_self_link
  subnet_self_link              = data.terraform_remote_state.vpc_ols_network.outputs.subnet_self_link
  pods_secondary_range_name     = data.terraform_remote_state.vpc_ols_network.outputs.pods_secondary_range_name
  services_secondary_range_name = data.terraform_remote_state.vpc_ols_network.outputs.services_secondary_range_name
  enable_autopilot              = true
  cluster_autoscaling = {
    enabled = false
    resource_limits = {
      cpu = {
        minimum = 2
        maximum = 8
      }
      memory = {
        minimum = 4
        maximum = 32
      }
    }
  }
  binary_authorization = {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE" # set to null to disable
  }
  network_policy = {
    enabled  = true
    provider = "CALICO"
  }
  datapath_provider = "ADVANCED_DATAPATH"

  master_authorized_networks_config = {
    cidr_blocks = {
      cidr_block   = "182.253.194.32/28"
      display_name = "my-home-public-ip"
    }
    gcp_public_cidrs_access_enabled = false
  }

  private_cluster_config = {
    dev = {
      enable_private_endpoint = false
      enable_private_nodes    = true
      master_ipv4_cidr_block  = "192.168.0.0/28"
    }
    stg = {
      enable_private_endpoint = true
      enable_private_nodes    = true
      master_ipv4_cidr_block  = "192.168.1.0/28"
    }
    prd = {
      enable_private_endpoint = true
      enable_private_nodes    = true
      master_ipv4_cidr_block  = "192.168.2.0/28"
    }
  }

  dns_config = {
    dev = {
      cluster_dns        = "CLOUD_DNS"
      cluster_dns_scope  = "VPC_SCOPE"
      cluster_dns_domain = "blast.local"
    }
    stg = {
      cluster_dns        = "CLOUD_DNS"
      cluster_dns_scope  = "VPC_SCOPE"
      cluster_dns_domain = "blast.local"
    }
    prd = {
      cluster_dns        = "CLOUD_DNS"
      cluster_dns_scope  = "VPC_SCOPE"
      cluster_dns_domain = "blast.local"
    }
  }
  #node pool only work when
  node_config = {
    ondemand = {
      is_spot    = false
      node_count = 1
      machine_type = {
        dev = "e2-medium"
        stg = "e2-standard-2"
        prd = "e2-standard-4"
      }
      disk_size_gb    = 20
      disk_type       = ["pd-standard", "pd-ssd"]
      service_account = data.google_service_account.gcompute_engine_default_service_account.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      tags            = ["ondemand"]
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_integrity_monitoring = false
      }
    },
    spot = {
      is_spot    = true
      node_count = 0
      machine_type = {
        dev = "e2-medium"
        stg = "e2-standard-2"
        prd = "e2-standard-4"
      }
      disk_size_gb    = 20
      disk_type       = ["pd-standard", "pd-ssd"]
      service_account = data.google_service_account.gcompute_engine_default_service_account.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      tags            = ["spot"]
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_integrity_monitoring = false
      }
    }
  }

  autoscaling = {
    ondemand = {
      # min_node_count  = 2
      # max_node_count  = 20
      # location_policy = "BALANCED"
    }
    spot = {
      min_node_count  = 2
      max_node_count  = 20
      location_policy = "ANY"
    }
  }

  node_management = {
    auto_repair  = false
    auto_upgrade = false
  }
}
