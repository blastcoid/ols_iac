
# Google Compute Engine (GCE) Deployment for Atlantis Server

## Overview

This deployment sets up an Atlantis server on Google Compute Engine (GCE) using the `infrastructure/gcp/cloud-deployment/gcompute-engine-atlantis` module. Atlantis is a self-hosted platform that provides a unified workflow for collaborating on Terraform. Here's what's included:

- **SSH Key Generation**: Creates an RSA private key for SSH access.
- **Service Account Configuration**: Utilizes a specific Google service account for the GCE instance.
- **Compute Engine Instance Creation**: Provisions a GCE instance with custom configurations.
- **DNS Record Configuration**: Optionally creates a DNS record for the GCE instance.
- **Firewall Rule Configuration**: Sets up firewall rules for the GCE instance.
- **Ansible Playbook Execution**: Optionally runs an Ansible playbook for further provisioning.

## Usage

### Terraform State Storage Configuration

```hcl
terraform {
  backend "gcs" {
    bucket = "<GCS Bucket Name>"
    prefix = "gcompute-engine/atlantis-server"
  }
}
```

### Deploying the Atlantis Server using the GCompute Engine module

```hcl
module "gcompute-engine-atlantis" {
  source = "../../modules/compute/gcompute-engine"
  // ... other variables ...
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
| instance_name               | The name of the GCE instance.                        |
| instance_zone               | The zone of the GCE instance.                        |
| instance_public_ip          | The public IP address of the GCE instance.           |
| instance_private_ip         | The private IP address of the GCE instance.          |
| dns_record_name             | The name of the DNS record (if created).             |
| dns_record_type             | The type of the DNS record (if created).             |
| dns_record_ttl              | The TTL of the DNS record (if created).              |

---