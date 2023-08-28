
---

# GKE (Google Kubernetes Engine) Module for Google Cloud Platform (GCP)

This Terraform module provisions a Google Kubernetes Engine (GKE) cluster on GCP, along with associated resources like node pools, network policies, and cluster role bindings.

## Features

- **Cluster Creation**: Provisions a GKE cluster with configurable settings for private endpoints, autoscaling, binary authorization, and more.
- **Node Pool Management**: Defines multiple node pools with support for on-demand and spot instances, shielded instance configurations, and auto-scaling.
- **Network Policy Configuration**: Enables network policies with support for various providers like Calico, Cilium, etc.
- **DNS Configuration**: Configures DNS within the cluster, including DNS scope and domain settings.
- **Cluster Role Binding**: Defines cluster role bindings for client cluster admin.
- **Autopilot Support**: Optionally enables GKE Autopilot, a fully managed Kubernetes service.
- **Binary Authorization**: Configures Binary Authorization to ensure only trusted container images are deployed.

## Usage

```hcl
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| region | The GCP region where resources will be created. | string | n/a | yes |
| unit | The business unit code representing the organizational unit. | string | n/a | yes |
| env | The environment stage (e.g., dev, prod) where the infrastructure will be deployed. | string | n/a | yes |
| code | The service domain code representing the specific service or application. | string | n/a | yes |
| feature | The specific feature or component of the AWS service being configured. | string | n/a | yes |
| issue_client_certificate | Whether to issue a client certificate for authenticating to the cluster. | bool | n/a | yes |
| vpc_self_link | The self-link URL of the VPC where the cluster will be created. | string | n/a | yes |
| subnet_self_link | The self-link URL of the subnet where the cluster will be created. | string | n/a | yes |
| private_cluster_config | Configuration for enabling private endpoints and nodes within the cluster. | map(object) | n/a | yes |
| enable_autopilot | Whether to enable GKE Autopilot, a fully managed Kubernetes service. | bool | n/a | yes |
| cluster_autoscaling | Configuration for enabling cluster autoscaling, including resource limits for CPU and memory. | object | n/a | yes |
| binary_authorization | Configuration for Binary Authorization, which ensures only trusted container images are deployed. | object | n/a | yes |
| network_policy | Configuration for network policies, which control communication between Pods. | object | n/a | yes |
| datapath_provider | The provider for the datapath, which controls how data is routed within the cluster. | string | `null` | no |
| dns_config | Configuration for DNS within the cluster, including DNS scope and domain settings. | map(object) | n/a | yes |
| pods_secondary_range_name | The name of the secondary IP range for Pods in the cluster. | string | n/a | yes |
| services_secondary_range_name | The name of the secondary IP range for Services in the cluster. | string | n/a | yes |
| node_config | Configuration for on-demand and spot nodes, including machine type, disk size, and other settings. | map(object) | n/a | yes |
| node_management | Configuration for node management, including auto-repair and auto-upgrade settings. | object | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The unique identifier of the GKE cluster. |
| cluster_name | The name of the GKE cluster. |
| cluster_endpoint | The endpoint URL for accessing the GKE cluster. |
| cluster_ca_certificate | The CA certificate used for authenticating to the GKE cluster. |
| cluster_location | The location (region or zone) of the GKE cluster. |
| cluster_master_version | The master version of the GKE cluster. |
| cluster_node_version | The node version of the GKE cluster. |
| cluster_node_pools | The node pools associated with the GKE cluster. |

## Requirements

- Terraform v0.14 or higher
- Google Cloud Platform (GCP) account with appropriate permissions
- Google Cloud SDK (gcloud) installed and configured

---