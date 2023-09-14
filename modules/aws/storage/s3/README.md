
---

# Terraform AWS S3 Bucket Module

This Terraform module provides a reusable, best-practice configuration for creating AWS S3 buckets with associated IAM policies and other essential configurations.

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [Inputs](#inputs)
5. [Outputs](#outputs)
6. [Contributing](#contributing)
7. [License](#license)

## Features

- Create S3 Bucket with a standard naming convention
- Attach IAM policies for bucket access
- Configure bucket ACLs
- Enable/Disable force destroy for the bucket
- Apply bucket ownership controls

## Requirements

- Terraform 1.5.5 or newer
- AWS Provider 5.16.0 or newer

## Usage

1. Add the module to your Terraform configuration:

```hcl
module "s3_bucket" {
  source = "./modules/aws/storage/s3"

  region  = "us-west-1"
  standard = {
    unit    = "ols"
    env     = "dev"
    code    = "stor"
    feature = "s3"
    sub     = "tfstate"
  }
  s3_acl          = "private"
  s3_force_destroy = false
}
```

2. Initialize Terraform:

```sh
terraform init
```

3. Apply the changes:

```sh
terraform apply
```

## Inputs

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region where resources will be created | - |
| `standard` | Map containing standard naming conventions for resources | - |
| `s3_acl` | Canned ACL to apply to the bucket | `private` |
| `s3_force_destroy` | Whether to forcefully delete all objects in the bucket | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `bucket_id` | The name of the bucket |
| `bucket_arn` | The ARN of the bucket |

## License

This project is licensed under the terms of the [Apache License](https://github.com/blastcoid/ols_iac/blob/main/LICENSE).

---