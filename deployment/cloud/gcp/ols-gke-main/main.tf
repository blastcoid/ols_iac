# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/compute/ols-dev-compute-gke-main"
  }
}

data "google_service_account" "gcompute_engine_default_service_account" {
  account_id = "102052325554983869202"
}

data "terraform_remote_state" "vpc_main" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/network/ols-dev-network-vpc-main"
  }
}

# create gke from modules gke
module "gke_main" {
  source                        = "../../../../modules/gcp/compute/gke"
  region                        = var.region
  env                           = var.env
  cluster_name                  = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  issue_client_certificate      = false
  vpc_self_link                 = data.terraform_remote_state.vpc_main.outputs.network_vpc_self_link
  subnet_self_link              = data.terraform_remote_state.vpc_main.outputs.network_subnet_self_link
  pods_secondary_range_name     = data.terraform_remote_state.vpc_main.outputs.network_pods_secondary_range_name
  services_secondary_range_name = data.terraform_remote_state.vpc_main.outputs.network_services_secondary_range_name
  enable_autopilot              = true
  binary_authorization = {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE" # set to null to disable
  }
  network_policy = {
    enabled  = false
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
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "192.168.0.0/28"
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
  resource_labels = {
    name    = "${var.unit}-${var.env}-${var.code}-${var.feature}"
    env     = var.env
    unit    = var.unit
    code    = var.code
    feature = var.feature
  }
  # node pool only work when enable_autopilot = false
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
      workload_metadata_config = {
        mode = "GKE_METADATA"
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
      workload_metadata_config = {
        mode = "GKE_METADATA"
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
