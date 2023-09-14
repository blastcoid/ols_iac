# Terraform AWS VPC Module

---

## Table of Contents

- [Description](#description)
- [Requirements](#requirements)
- [Providers](#providers)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This module provisions a VPC in AWS with highly customizable options, such as multiple subnets across Availability Zones, Internet and NAT Gateways, and route table associations. The module follows best practices and community standards, offering both resource creation and output variables.

## Features

- Provision a flexible, customizable AWS VPC.
- Multiple subnet types: Node, App, Data, and Public.
- Internet Gateway and NAT Gateway support.
- Route tables with associations for various subnet types.
- Dynamic Elastic IP allocation for NAT Gateways.
- Well-tagged resources for easy identification and management.
- Extendable through additional CIDR block association.
- Conditionally create resources based on environment variables.

---

## Requirements

| Name      | Version    |
|-----------|------------|
| terraform | >= 5.15.5  |

---

## Providers

| Name | Version |
|------|---------|
| aws  | >= 5.16.1 |

---

## Inputs

| Name                     | Description                                                                | Type         | Default       |
|--------------------------|----------------------------------------------------------------------------|--------------|---------------|
| `region`                 | The AWS region where resources will be created.                            | `string`     | `"us-west-2"` |
| `standard`               | A map containing standard naming convention variables for resources.       | `map(string)`|               |
| `vpc_cidr`               | The CIDR block for the VPC.                                                | `string`     |               |
| `vpc_app_cidr`           | The CIDR block for the application subnet within the VPC.                  | `string`     |               |
| `vpc_enable_dns_support` | A boolean flag to enable/disable DNS support in the VPC.                   | `bool`       | `false`       |
| `vpc_enable_dns_hostnames`| A boolean flag to enable/disable DNS hostnames in the VPC.                | `bool`       | `false`       |
| `vpc_instance_tenancy`   | A tenancy option for instances launched into the VPC (default, dedicated). | `string`     | `default`     |
| `nat_total_eip`          | The total number of Elastic IPs for the NAT Gateway.                       | `number`     |               |

---

## Outputs

| Name                     | Description                                       |
|--------------------------|---------------------------------------------------|
| `vpc_id`                 | The ID of the VPC.                                |
| `vpc_secondary_cidr_id`  | The ID of the secondary CIDR block association.   |
| `vpc_arn`                | The ARN of the VPC.                               |
| `vpc_cidr_block`         | The primary CIDR block of the VPC.                |
| `vpc_secondary_cidr_block`| The secondary CIDR block of the VPC.             |
| `node_id`                | The IDs of the node subnets.                      |
| `node_arn`               | The ARNs of the node subnets.                     |
| `app_id`                 | The IDs of the app subnets.                       |
| `app_arn`                | The ARNs of the app subnets.                      |
| `data_id`                | The IDs of the data subnets.                      |
| `data_arn`               | The ARNs of the data subnets.                     |
| `public_id`              | The IDs of the public subnets.                    |
| `public_arn`             | The ARNs of the public subnets.                   |

---

## Usage

```hcl
module "vpc_main" {
  source = "../../modules/aws/network/vpc"
  region = "us-west-1"
  standard = {
    unit    = "ols"
    env     = "mstr"
    code    = "net"
    feature = "vpc"
    sub     = "main"
  }
  vpc_cidr                 = "10.0.0.0/16"
  vpc_app_cidr             = "100.64.0.0/16"
  vpc_enable_dns_support   = true
  vpc_enable_dns_hostnames = true
  nat_total_eip            = 1
}
```

---

## License

This project is licensed under the terms of the [Apache License](https://github.com/blastcoid/ols_iac/blob/main/LICENSE).

---