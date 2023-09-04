# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcp/compute/ols-dev-compute-gce-atlantis"
  }
}

# Terraform state data vpc network
data "terraform_remote_state" "vpc_ols_network" {
  backend = "gcs"

  config = {
    bucket = "${var.unit}-${var.env}-storage-gcs-tfstate"
    prefix = "gcp/network/${var.unit}-${var.env}-network-vpc-main"
  }
}

# Terraform state data gkubernetes engine
data "terraform_remote_state" "gke_main" {
  backend = "gcs"

  config = {
    bucket = "${var.unit}-${var.env}-storage-gcs-tfstate"
    prefix = "gcp/compute/${var.unit}-${var.env}-compute-gke-main"
  }
}

# Terraform state data gcloud dns
data "terraform_remote_state" "dns_blast" {
  backend = "gcs"

  config = {
    bucket = "${var.unit}-${var.env}-storage-gcs-tfstate"
    prefix = "gcp/network/${var.unit}-${var.env}-network-dns-blast"
  }
}

data "google_secret_manager_secret_version" "ssh_key" {
  secret = "ssh-key-main"
}

data "google_secret_manager_secret_version" "github_token" {
  secret = "github-token-atlantis"
}

data "google_secret_manager_secret_version" "github_secret" {
  secret = "github-secret"
}

data "google_secret_manager_secret_version" "atlantis_password" {
  secret = "atlantis-password"
}

# Get current project id
data "google_project" "current" {}

# create gce from modules gce
module "gcompute-engine" {
  source               = "../../../../modules/gcp/compute/gce"
  region               = var.region
  env                  = var.env
  zone                 = "${var.region}-a"
  project_id           = data.google_project.current.project_id
  instance_name        = "${var.unit}-${var.env}-${var.code}-${var.feature}"
  service_account_role = "roles/owner"
  linux_user           = var.feature
  ssh_key              = data.google_secret_manager_secret_version.ssh_key.secret_data
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
  tags              = [var.feature]
  image             = "debian-cloud/debian-11"
  create_dns_record = true
  dns_config = {
    dns_name      = data.terraform_remote_state.dns_blast.outputs.dns_name
    dns_zone_name = data.terraform_remote_state.dns_blast.outputs.dns_zone_name
    record_type   = "A"
    ttl           = 300
  }
  run_ansible       = true
  ansible_tags      = ["configure_kubectl"]
  ansible_skip_tags = []
  ansible_vars = {
    # ansible_user                 = var.feature
    # ansible_ssh_private_key_file = "${var.feature}/id_rsa.pem"
    # ansible_python_interpreter   = "/usr/bin/python3"
    project_id                   = data.google_project.current.project_id
    cluster_name                 = data.terraform_remote_state.gke_main.outputs.cluster_name
    region                       = "${var.region}-a"
    github_token                 = data.google_secret_manager_secret_version.github_token.secret_data
    github_secret                = data.google_secret_manager_secret_version.github_secret.secret_data
    atlantis_password            = data.google_secret_manager_secret_version.atlantis_password.secret_data
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
  target_tags   = [var.feature]
}
