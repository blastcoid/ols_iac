# Terraform AWS ECR Module

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
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

This module creates and manages an Amazon ECR (Elastic Container Registry) with options for image scanning, lifecycle policies, and encryption. The module adheres to best practices and community standards, offering both resource creation and output variables.

## Features

- Create and manage AWS ECR repositories.
- Configure image tag mutability.
- Image scanning options (on push and scheduled).
- Optional force delete for repositories.
- Dynamic encryption settings.
- Well-tagged ECR resources for easy identification.

---

## Requirements

| Name      | Version    |
|-----------|------------|
| terraform | >= 0.14.0  |

---

## Providers

| Name | Version |
|------|---------|
| aws  | >= 3.0  |

---

## Inputs

| Name                     | Description                                                | Type       | Default  |
|--------------------------|------------------------------------------------------------|------------|----------|
| `region`                 | The AWS region where resources will be created.            | `string`   | "us-west-2" |
| `standard`               | A map containing standard naming convention variables.     | `map(string)` | |
| `image_tag_mutability`   | Image tag mutability setting.                              | `string`   | |
| `scan_on_push`           | Enable/Disable image scanning on push.                     | `bool`     | |
| `force_delete`           | Enable/Disable force delete for the repository.            | `bool`     | |
| `encryption_configuration` | Encryption settings for the repository.                  | `object`   | |
| `ecr_lifecycle_policy`   | ECR Lifecycle policy document.                             | `string`   | |
| `scan_type`              | The type of scan to run.                                   | `string`   | |

---

## Outputs

| Name                   | Description                   |
|------------------------|-------------------------------|
| `repository_id`        | The ID of the repository.     |
| `repository_arn`       | The ARN of the repository.    |
| `repository_url`       | The URL of the repository.    |

---

## Usage

```hcl
module "ecr_main" {
  source = "../../modules/aws/container/ecr"
  region = "us-west-1"
  standard = {
    unit    = "ols"
    env     = "dev"
    code    = "ecr"
    feature = "svc"
    sub     = "sample"
  }
  image_tag_mutability   = "MUTABLE"
  scan_on_push           = true
  force_delete           = false
  ecr_lifecycle_policy   = "your_policy_here"
  scan_type              = "BASIC"
}
```

---

## License

This project is licensed under the terms of the [Apache License](https://github.com/blastcoid/ols_iac/blob/main/LICENSE).

---