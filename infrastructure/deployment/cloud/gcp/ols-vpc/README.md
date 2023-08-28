
---

# Google Cloud VPC Deployment for OLS Network

This deployment sets up a Google Cloud VPC for the OLS network using the `module/network/vpc` module.

## Overview

- Configures a GCS backend for Terraform state storage.
- Sets up a Google Cloud VPC with custom subnetworks and secondary IP ranges for GKE pods and services.
- Creates a Google Compute Router and NAT for the VPC.
- Configures firewall rules for the VPC.
- Configures the Google Cloud provider for Terraform.

## Usage

### Terraform State Storage Configuration

```hcl
terraform {
  backend "gcs" {
    bucket = "<GCS Bucket Name>"
    prefix = "<GCS Bucket Prefix e.g vpc/ols-dev-vpc-networks>"
  }
}
```

### Deploying the VPC using the VPC Module

```hcl
module "vpc" {
  source  = "../../modules/network/vpc"
  region  = <GCP Region>
  unit    = <Business Unit Code>
  env     = <Environment> # dev, stg, or prd
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
    ],
    stg = [
      {
        range_name    = "pods-range"
        ip_cidr_range = "172.18.0.0/16"
      },
      {
        range_name    = "services-range"
        ip_cidr_range = "172.19.0.0/16"
      }
    ],
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
    <firewall_rule_name> = {
      name          = "<Firewall Rule Name>"
      description   = "<Description>"
      direction     = "<Direction>"
      allow         = [
        {
          protocol = "<Protocol>"
          ports    = ["<Port Range 1>", "<Port Range 2>", ...]
        }
      ]
      source_ranges = {
        any    = ["<Any Source Range>"],
        dev    = ["<Dev Source Range>"],
        stg    = ["<Stg Source Range>"],
        prd    = ["<Prd Source Range>"]
      }
      priority      = <Priority>
    }
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

| Name                 | Description                                          |
|----------------------|------------------------------------------------------|
| vpc_id               | The ID of the VPC being created.                     |
| vpc_self_link        | The URI of the VPC being created.                    |
| vpc_gateway_ipv4     | The IPv4 address of the VPC's gateway.               |
| subnet_self_link     | The URI of the subnetwork.                           |
| subnet_ip_cidr_range | The IP CIDR range of the subnetwork.                 |
| pods_secondary_range_name | The name of the secondary IP range for pods. |
| services_secondary_range_name | The name of the secondary IP range for services. |
| router_id            | The ID of the router.                                |
| router_self_link     | The URI of the router.                               |
| nat_id               | The ID of the NAT.                                   |
| firewall_ids         | The IDs of the firewall rules.                       |
| firewall_self_links  | The URIs of the firewall rules.                      |

---