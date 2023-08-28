
---

# Google Kubernetes Engine (GKE) Deployment for OLS Network

This deployment sets up a Google Kubernetes Engine (GKE) cluster for the OLS network using the `infrastructure/GCP/cloud-deployment/gkubernetes-engine-ols` module.

## Overview

- **Terraform State Storage**: Configures a GCS backend for Terraform state storage.
- **Service Account Configuration**: Utilizes a specific Google service account for the GKE cluster.
- **VPC and Subnet Integration**: Integrates with existing VPC and subnet using remote state data.
- **GKE Cluster Creation**: Provisions a GKE cluster with custom configurations for different environments (dev, stg, prd).
- **Autopilot Mode**: Optionally enables GKE Autopilot for a fully managed Kubernetes service.
- **Cluster Autoscaling**: Configures autoscaling for the cluster with custom CPU and memory limits.
- **Binary Authorization**: Implements Binary Authorization with specific evaluation mode.
- **Network Policy**: Enables network policies with a specific provider.
- **Datapath Provider**: Configures the datapath provider for the cluster.
- **Private Cluster Configuration**: Defines private cluster settings for different environments.
- **DNS Configuration**: Sets up custom DNS configurations for different environments.
- **Node Configuration**: Defines on-demand and spot node configurations, including machine types, disk sizes, and other settings.
- **Node Management**: Configures node management settings, including auto-repair and auto-upgrade.
- **Google Cloud Provider Configuration**: Sets up the Google Cloud provider for Terraform.

## Usage

### Terraform State Storage Configuration

```hcl
terraform {
  backend "gcs" {
    bucket = "<GCS Bucket Name>"
    prefix = "gkubernetes-engine/ols-dev-gkubernetes-engine-ols"
  }
}
```

### Deploying the GKE Cluster using the GKE Module

```hcl
# Terraform State Storage
terraform {
  backend "gcs" {
    bucket = "<GCS Bucket Name>"
    prefix = "gkubernetes-engine/ols-dev-gkubernetes-engine-ols"
  }
}

data "google_service_account" "gcompute_engine_default_service_account" {
  account_id = "<service account id>"
}

data "terraform_remote_state" "vpc_ols_network" {
  backend = "gcs"

  config = {
    bucket = "<GCS Bucket Name>"
    prefix = "vpc/ols-dev-vpc-network"
  }
}

# create gke from modules gke
module "gkubernetes_engine" {
  # Naming standard
  source = "<path_to_module_directory>"

  region = "<GCP Region>"
  unit   = "<Business Unit Code>"
  env    = "<Environment>" # dev, stg, or prd
  code   = "gkubernetes-engine"
  feature = "cluster"
  # cluster arguments
  issue_client_certificate      = true
  vpc_self_link                 = <vpc self link>
  subnet_self_link              = <subnet self link>
  pods_secondary_range_name     = <pods secondary range name>
  services_secondary_range_name = <services secondary range name>
  services_secondary_range_name = <services secondary range name>
  enable_autopilot              = true
  cluster_autoscaling = {
    enabled = true
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
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }
  network_policy = {
    enabled  = true
    provider = "CALICO"
  }
  datapath_provider = "ADVANCED_DATAPATH"
  private_cluster_config = {
    dev = {
      enable_private_endpoint = false
      enable_private_nodes    = true
      master_ipv4_cidr_block  = <master ipv4 cidr block for dev>
    }
    stg = {
      enable_private_endpoint = true
      enable_private_nodes    = true
      master_ipv4_cidr_block  = <master ipv4 cidr block for staging>
    }
    prd = {
      enable_private_endpoint = true
      enable_private_nodes    = true
      master_ipv4_cidr_block  = <master ipv4 cidr block for production>
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
      service_account = <service account for ondemand>
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
      service_account = <service account for spot>
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
      tags            = ["spot"]
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_integrity_monitoring = false
      }
      min_node_count = 0
      max_node_count = 20
    }
  }
  node_management = {
    auto_repair  = false
    auto_upgrade = false
  }
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
   ```hcl
   provider "google" {
     credentials = file("<PATH_TO_SERVICE_ACCOUNT_JSON_KEY>")
     project     = "ols-platform-dev"
     region      = "asia-southeast2"
   }
   ```

2. **Environment Variable**: Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of your service account JSON key.
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="<PATH_TO_SERVICE_ACCOUNT_JSON_KEY>"
   ```

3. **Default Credentials**: If you're running Terraform on a GCP environment (like a Compute Engine instance), it can use the default service account associated with the instance or environment.

## Outputs

| Name                        | Description                                          |
|-----------------------------|------------------------------------------------------|
| cluster_id                  | The unique identifier of the GKE cluster.            |
| cluster_name                | The name of the GKE cluster.                         |
| cluster_location            | The location (region or zone) of the GKE cluster.    |
| cluster_self_link           | The self-link of the GKE cluster.                    |
| cluster_endpoint            | The IP address of the Kubernetes master endpoint.    |
| cluster_client_certificate  | The public certificate for client authentication.    |
| cluster_client_key          | The private key for client authentication.           |
| cluster_master_version      | The version of the Kubernetes master for the GKE cluster. |

---