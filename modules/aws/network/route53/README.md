
---

# Terraform AWS Route53 Module

This Terraform module provides a reusable, best-practice configuration for creating and managing AWS Route53 zones.

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [Inputs](#inputs)
5. [Outputs](#outputs)
6. [Contributing](#contributing)
7. [License](#license)

## Features

- Create and manage Route53 zones.
- Attach Route53 zone with a standard naming convention.
- Force destroy option for Route53 zone.
- Well-tagged Route53 resources for easy identification.

## Requirements

- Terraform 1.5.5 or newer
- AWS Provider 5.16.0 or newer

## Usage

To use the module, add the following code to your Terraform configuration:

```hcl
module "route53_zone" {
  source = "./modules/aws/network/route53"

  region  = "us-west-2"
  standard = {
    unit    = "ols"
    env     = "dev"
    code    = "net"
    feature = "route53"
    sub     = "main"
  }
  route53_zone_name     = "ols.blast.co.id."
  route53_force_destroy = true
}
```

Run the following commands:

```bash
terraform init
terraform apply
```

## Inputs

| Variable             | Description                                                                                   | Default     |
|----------------------|-----------------------------------------------------------------------------------------------|-------------|
| `region`             | AWS region where the Route53 zone will be created.                                             | `us-west-2` |
| `standard`           | A map containing elements for standard naming convention.                                      | -           |
| `route53_zone_name`  | The fully-qualified domain name for the Route53 hosted zone.                                   | -           |
| `route53_force_destroy` | Boolean flag to forcefully delete the zone and all records when destroying the resource.   | `false`     |

## Outputs

| Output               | Description                                                                                   |
|----------------------|-----------------------------------------------------------------------------------------------|
| `route53_zone_id`    | The unique ID of the created Route53 hosted zone.                                              |
| `route53_name_servers`| A list of name servers in the associated (sub) delegation set.                                 |
| `route53_arn`        | The Amazon Resource Name (ARN) of the Route53 hosted zone.                                     |
| `primary_name_server`| A list of primary name servers for the Route53 hosted zone. Typically the same as `route53_name_servers`. |

## License

This project is licensed under the terms of the [Apache License](https://github.com/blastcoid/ols_iac/blob/main/LICENSE).