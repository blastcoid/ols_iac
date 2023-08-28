# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcompute-engine/ols-dev-gcompute-engine-atlantis"
  }
}

# Terraform state data vpc network
data "terraform_remote_state" "vpc_ols_network" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "vpc/ols-dev-vpc-network"
  }
}

# Terraform state data gkubernetes engine
# data "terraform_remote_state" "gkubernetes_engine_ols" {
#   backend = "gcs"

#   config = {
#     bucket = "ols-dev-storage-gcs-tfstate"
#     prefix = "gkubernetes-engine/ols-dev-gkubernetes-engine-ols"
#   }
# }

# Terraform state data gcloud dns
data "terraform_remote_state" "gcloud_dns_ols" {
  backend = "gcs"

  config = {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcloud-dns/ols-dev-gcloud-dns-blast"
  }
}

data "google_secret_manager_secret_version" "github_token" {
  secret = "github-token"
}

data "google_secret_manager_secret_version" "github_secret" {
  secret = "github-webhook-secret"
}

# data "google_secret_manager_secret_version" "atlantis_password" {
#   secret = "atlantis-password"
# }

# Get current project id
data "google_project" "current" {}

# create gce from modules gce
module "gcompute-engine" {
  source               = "../../modules/compute/gcompute-engine"
  region               = "asia-southeast2"
  unit                 = "ols"
  env                  = "dev"
  code                 = "gce"
  feature              = ["atlantis"]
  zone                 = "asia-southeast2-a"
  project_id           = data.google_project.current.project_id
  service_account_role = "roles/owner"
  linux_user           = "atlantis"
  machine_type         = "e2-medium"
  disk_size            = 20
  disk_type            = "pd-standard"
  network_self_link    = data.terraform_remote_state.vpc_ols_network.outputs.vpc_self_link
  subnet_self_link     = data.terraform_remote_state.vpc_ols_network.outputs.subnet_self_link
  is_public            = true
  access_config = {
    dev = {
      nat_ip                 = ""
      public_ptr_domain_name = ""
      network_tier           = "STANDARD"
    }
    stg = {
      nat_ip                 = ""
      public_ptr_domain_name = ""
      network_tier           = "PREMIUM"
    }
    prd = {
      nat_ip                 = ""
      public_ptr_domain_name = ""
      network_tier           = "PREMIUM"
    }
  }
  tags              = ["atlantis"]
  image             = "debian-cloud/debian-11"
  create_dns_record = true
  dns_config = {
    dns_name      = data.terraform_remote_state.gcloud_dns_ols.outputs.dns_name
    dns_zone_name = data.terraform_remote_state.gcloud_dns_ols.outputs.dns_zone_name
    record_type   = "A"
    ttl           = 300
  }
  run_ansible       = true
  ansible_tags      = ["configure_kubectl"]
  ansible_skip_tags = []
  ansible_vars = {
    project_id            = data.google_project.current.project_id
    cluster_name          = "ols-dev-gkubernetes-engine-ols"
    region                = "asia-southeast2" # asia-southeast2-a for zonal cluster
    github_token          = data.google_secret_manager_secret_version.github_token.secret_data
    github_secret = data.google_secret_manager_secret_version.github_secret.secret_data
    atlantis_password     = "Makanan13"
  }
  firewall_rules = {
    "ssh" = {
      protocol = "tcp"
      ports    = ["22"]
    }
    "http" = {
      protocol = "tcp"
      ports    = ["80"]
    }
    "atlantis" = {
      protocol = "tcp"
      ports    = ["4141"]
    }
    "https" = {
      protocol = "tcp"
      ports    = ["443"]
    }
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["atlantis"]
}
