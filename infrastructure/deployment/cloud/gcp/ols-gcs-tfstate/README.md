
---

# Google Cloud Storage Terraform Deployment for Terraform State Storage

This deployment utilizes the Google Cloud Storage Terraform module to create a backend for storing Terraform state files (`tfstate`).

## Overview

- Configures a GCS bucket to store Terraform state files.
- Uses the Google Cloud Storage Terraform module for bucket creation.
- Sets up the Google Cloud provider for Terraform.

## Usage

### Terraform State Storage Configuration

```hcl
terraform {
  backend "gcs" {
    bucket  = "ols-dev-storage-gcs-tfstate"
    prefix  = "gcs/ols-dev-storage-gcs-tfstate"
  }
}
```

### Create GCS Bucket using the GCloud Storage Module

```hcl
module "gcloud-storage-tfstate" {
  source                   = "../../modules/storage/gcloud-storage"
  region                   = "<GCP Region>"
  unit                     = "<Business Unit Code>"
  env                      = "<Environment>"
  code                     = "<Service Domain Code>"
  feature                  = "<Feature Name>"
  force_destroy            = true
  public_access_prevention = "enforced"
}
```

### Google Cloud Provider Configuration

```hcl
provider "google" {
  project     = "<GCP Project ID>"
  region      = "<GCP Region>"
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

| Name             | Description                       |
|------------------|-----------------------------------|
| bucket_name      | The name of the GCS bucket.       |
| bucket_url       | The URL of the GCS bucket.        |
| bucket_self_link | The link to the bucket resource in GCP. |

---