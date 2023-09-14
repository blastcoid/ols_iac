
---

# Terraform AWS KMS Module

This Terraform module provides a configurable and reusable setup for creating AWS KMS keys with associated policies and aliases.

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [Inputs](#inputs)
5. [Outputs](#outputs)
6. [Contributing](#contributing)

## Features

- Create Customer-Managed KMS keys
- Attach KMS key policies
- Create KMS key aliases
- Enable or disable key rotation
- Configure deletion window for key
- Supports standard naming convention for resources

## Requirements

- Terraform 1.0.0 or newer
- AWS Provider 3.0.0 or newer

## Usage

```hcl
module "kms" {
  source = "./modules/aws/security/kms"

  region                     = "us-west-2"
  standard                   = {
    unit    = "devops"
    env     = "prod"
    code    = "sec"
    feature = "kms"
    sub     = "001"
  }
  kms_key_usage              = "ENCRYPT_DECRYPT"
  kms_deletion_window_in_days= 30
  kms_enable_key_rotation    = true
  kms_is_enabled             = true
  kms_policy                 = file("policy.json")
  kms_customer_master_key_spec = "SYMMETRIC_DEFAULT"
}
```

Initialize Terraform and apply the changes:

```bash
terraform init
terraform apply
```

## Inputs

| Variable                       | Description                                                                                          | Default                |
|--------------------------------|------------------------------------------------------------------------------------------------------|------------------------|
| `region`                       | AWS region                                                                                           | `us-west-2`            |
| `standard`                     | Map containing standard naming conventions for resources                                              | -                      |
| `kms_key_usage`                | Specifies the intended use of the key                                                                | `ENCRYPT_DECRYPT`      |
| `kms_deletion_window_in_days`  | Duration in days after which the key is deleted                                                       | -                      |
| `kms_enable_key_rotation`      | Specifies whether key rotation is enabled                                                            | `false`                |
| `kms_is_enabled`               | Specifies whether the key is enabled                                                                 | `true`                 |
| `kms_policy`                   | A valid policy JSON document                                                                         | -                      |
| `kms_customer_master_key_spec` | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports | `SYMMETRIC_DEFAULT` |

## Outputs

| Output        | Description                                          |
|---------------|------------------------------------------------------|
| `key_arn`     | The Amazon Resource Name (ARN) of the KMS key.       |
| `key_id`      | The globally unique identifier for the KMS key.      |
| `alias_arn`   | The ARN of the KMS alias.                            |
| `alias_name`  | The display name of the alias. Starts with 'alias/'. |

## License

This project is licensed under the terms of the [Apache License](https://github.com/blastcoid/ols_iac/blob/main/LICENSE).

---
