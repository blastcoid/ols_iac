
---

# VPC Module for Google Cloud Platform (GCP)

This Terraform module provisions a Virtual Private Cloud (VPC) on GCP, along with associated resources like subnetworks, routers, and Cloud NAT.

## Features

- **VPC Creation**: Provisions a VPC without default subnets for granular control.
- **Subnetwork Creation**: Defines a subnetwork within the VPC with CIDR ranges determined based on the environment (`dev`, `stg`, or `prd`).
- **Router Creation**: Sets up a router to manage traffic routing and connect the VPC to external networks.
- **Cloud NAT Creation**: Allows VM instances without external IPs to access the internet. Supports both auto-allocated and manually specified IPs.
- **Firewall Rule Creation**: Configures firewall rules for the VPC based on provided specifications.

## Usage

```hcl
module "vpc" {
  source = "<path_to_module_directory>"

  region = "<GCP Region>"
  unit   = "<Business Unit Code>"
  env    = "<Environment>" # dev, stg, or prd
  code   = "vpc"
  feature = ["network", "subnet", "router", "address", "nat"]

  ip_cidr_range = {
    dev = "<CIDR for dev>"
    stg = "<CIDR for stg>"
    prd = "<CIDR for prd>"
  }

  secondary_ip_range = {
    dev = [
      {
        range_name    = "<Range Name for Pods in Development>"
        ip_cidr_range = "<CIDR for Pods in Dev>"
      },
      {
        range_name    = "<Range Name for Services in Dev>"
        ip_cidr_range = "<CIDR for Services in Dev>"
      }
    ],
    stg = [
      {
        range_name    = "<Range Name for Pods in Stg>"
        ip_cidr_range = "<CIDR for Pods in Stg>"
      },
      {
        range_name    = "<Range Name for Services in Stg>"
        ip_cidr_range = "<CIDR for Services in Stg>"
      }
    ],
    prd = [
      {
        range_name    = "<Range Name for Pods in Prd>"
        ip_cidr_range = "<CIDR for Pods in Prd>"
      },
      {
        range_name    = "<Range Name for Services in Prd>"
        ip_cidr_range = "<CIDR for Services in Prd>"
      }
    ]
  }

  nat_ip_allocate_option = "<NAT IP Allocation Option>" # AUTO_ONLY, MANUAL_ONLY
  source_subnetwork_ip_ranges_to_nat = "<Source Subnetwork IP Ranges to NAT Option>" # ALL_SUBNETWORKS_ALL_IP_RANGES, LIST_OF_SUBNETWORKS
  subnetworks = [
    {
      name = "<Subnetwork Name>"
      source_ip_ranges_to_nat = ["<Range 1>", "<Range 2>", ...]
    }
  ]
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| region | The GCP region where resources will be created. | string | n/a | yes |
| unit | Business unit code. | string | n/a | yes |
| env | Stage environment where the infrastructure will be deployed. | string | n/a | yes |
| code | Service domain code. | string | n/a | yes |
| feature | List of feature names. | list(string) | n/a | yes |
| ip_cidr_range | The primary IP CIDR range of the subnetwork based on the environment. | map(string) | n/a | yes |
| secondary_ip_range | Secondary IP ranges for GKE pods and services based on the environment. | map(list(object)) | n/a | yes |
| nat_ip_allocate_option | The way NAT IPs should be allocated. | string | n/a | yes |
| source_subnetwork_ip_ranges_to_nat | The way NAT IPs should be allocated. | string | n/a | yes |
| subnetworks | List of subnetworks to configure NAT for. | list(object) | n/a | yes |
| vpc_firewall_rules | 	Map of firewall rules to be applied to the VPC. | map(object) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC being created. |
| vpc_self_link | The URI of the VPC being created. |
| vpc_gateway_ipv4 | The IPv4 address of the VPC's gateway. |
| subnet_network | The network to which the subnetwork belongs. |
| subnet_self_link | The URI of the subnetwork. |
| subnet_ip_cidr_range | The IP CIDR range of the subnetwork. |
| pods_secondary_range_name | The name of the secondary IP range for pods. |
| services_secondary_range_name | The name of the secondary IP range for services. |
| router_id | The ID of the router being created. |
| router_self_link | The URI of the router being created. |
| nat_id | The ID of the NAT being created. |
| firewall_ids | The IDs of the firewall rule being created. |
| firewall_self_links | The URIs of the firewall rule being created. |

---