
---

# Google Compute Engine (GCE) Deployment for Bastion Server

## Overview

This deployment sets up a Google Compute Engine (GCE) for a bastion server using the `gcompute-engine` module. It includes configurations for Terraform state storage, authentication with Google Cloud, and specific settings for the GCE instance.

Key features of this deployment include:
- **Terraform State Storage**: Utilizes a GCS backend for Terraform state storage.
- **VPC and Subnet Integration**: Integrates with existing VPC and subnet using remote state data.
- **GCE Instance Creation**: Provisions a GCE instance with custom configurations for various environments (dev, stg, prd).
- **DNS Configuration**: Sets up custom DNS configurations.
- **Firewall Settings**: Sets up firewall rules for SSH.
- **Ansible Setup**: Runs Ansible playbook for setting up kubectl and other plugins.

## Usage

### Terraform State Storage Configuration

```hcl
terraform {
  backend "gcs" {
    bucket = "ols-dev-storage-gcs-tfstate"
    prefix = "gcompute-engine/ols-dev-gcompute-engine-bastion"
  }
}
```

### Deploying the Bastion Server using the GCompute Engine module

```hcl
module "gcompute-engine" {
  source               = "../../modules/compute/gcompute-engine"
  region               = "asia-southeast2"
  unit                 = "ols"
  env                  = "dev"
  code                 = "gce"
  feature              = ["bastion"]
  zone                 = "asia-southeast2-a"
  project_id           = data.google_project.current.project_id
  service_account_role = "roles/viewer"
  username             = "debian"
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
  tags              = ["bastion"]
  image             = "debian-cloud/debian-11"
  create_dns_record = true
  dns_config = {
    dns_name      = data.terraform_remote_state.gcloud_dns_ols.outputs.dns_name
    dns_zone_name = data.terraform_remote_state.gcloud_dns_ols.outputs.dns_zone_name
    record_type   = "A"
    ttl           = 300
  }
  run_ansible       = true
  ansible_tags      = ["initialization"]
  ansible_skip_tags = []
  ansible_vars = {
    project_id            = data.google_project.current.project_id
    cluster_name          = data.terraform_remote_state.gkubernetes_engine_ols.outputs.cluster_name
    region                = "asia-southeast2-a"
  }
  firewall_rules = {
    "ssh" = {
      protocol = "tcp"
      ports    = ["22"]
    }
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}
```

### Google Cloud Provider Configuration

```hcl
provider "google" {
  project     = "ols-platform-dev"
  region      = "asia-southeast2"
}
```

#### Authenticating with Google Cloud

To authenticate with Google Cloud, you can use one of the following methods:

1. **Service Account JSON Key**: Provide the path to the JSON key file of the service account.
2. **Environment Variable**: Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of your service account JSON key.
3. **Default Credentials**: If you're running Terraform on a GCP environment (like a Compute Engine instance), it can use the default service account associated with the instance or environment.

## Outputs

| Name        | Description                               |
|-------------|-------------------------------------------|
| public_ip   | The public IP of the GCE instance.        |
| private_ip  | The private IP of the GCE instance.       |

---