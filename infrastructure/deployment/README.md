# Infrastructure for GCP

This directory contains Terraform configurations for deploying resources on Google Cloud Platform (GCP). The configurations are modularized into different components to ensure reusability and maintainability.

## Modules

### A. Network
### A.1. **VPC (Virtual Private Cloud)**
- **File**: `modules/vpc/vpc.tf`
  - Creates a VPC.
  - Sets up a subnet within the VPC.
  - Configures secondary IP ranges for GKE pods and services.

- **Variables**: `modules/network/vpc/variables.tf`
  - Defines naming standards and subnet arguments.

- **Outputs**: `modules/network/vpc/outputs.tf`
  - Provides outputs for VPC ID, VPC self link, VPC gateway IPv4, and subnetwork details.


### A.2. **Cloud DNS**
- **File**: `modules/network/gcloud-dns/cloud-dns.tf`
  - Creates a Cloud DNS zone.
  - Configures the DNS zone with a specific DNS name.

- **Variables**: `modules/network/gcloud-dns/variables.tf`
  - Defines naming standards and DNS zone arguments.

- **Outputs**: `modules/network/gcloud-dns/outputs.tf`
  - Provides outputs for the DNS zone name, DNS zone self link, and DNS zone name servers.


## B. Compute
### B.1. **GCompute Engine**
- **File**: `modules/compute/gcompute-engine/compute-engine.tf`
  - Sets up a VM.
  - Configures a firewall rule for the VM.

- **Variables**: `modules/compute/gcompute-engine/variables.tf`
  - Defines naming standards and GCE-specific arguments.

- **Outputs**: `modules/compute/gcompute-engine/outputs.tf`


### B.2. **GKubernetes Engine**
- **File**: `modules/compute/gkubernetes-engine/gkubernetes-engine.tf`
  - Creates a GKE cluster with two node pools: on-demand and preemptible.
  - Configures node pools with specific machine types, tags, and OAuth scopes.

- **Variables**: `modules/compute/gkubernetes-engine/variables.tf`
  - Defines naming standards and GKE-specific arguments.

- **Outputs**: `modules/compute/gkubernetes-engine/outputs.tf`
  - Provides outputs for the GKE cluster name, GKE cluster self link, and GKE cluster endpoint.

### B.3. **Helm Chart**
- **File**: `modules/compute/helm/helm.tf`
  - Deploys a Helm chart to the GKE cluster.
  - Configures the Helm chart with specific values.

- **Variables**: `modules/compute/helm/variables.tf`
  - Defines naming standards and Helm-specific arguments.

- **Outputs**: `modules/compute/helm/outputs.tf`
  - Provides outputs for the Helm chart name, Helm chart self link, and Helm chart endpoint.


## C.Storage
### C.1. **GCloud Storage**
- **File**: `modules/storage/gcloud-storage/gcloud-storage.tf`
  - Creates a GCS bucket.
  - Configures the bucket with a specific location and public access prevention.

- **Variables**: `modules/storage/gcloud-storage/variables.tf`
  - Defines naming standards and GCS-specific arguments.

- **Outputs**: `modules/storage/gcloud-storage/outputs.tf`
  - Provides outputs for the bucket name, bucket URL, and bucket self link.

## D. Security

### D.1. **GCertificate Manager**
- **File**: `modules/security/gcertificate-manager/gcertificate-manager.tf`
  - Creates a GCP certificate.
  - Configures the certificate with a specific domain name.

- **Variables**: `modules/security/gcertificate-manager/variables.tf`
  - Defines naming standards and certificate arguments.

- **Outputs**: `modules/security/gcertificate-manager/outputs.tf`
  - Provides outputs for the certificate name, certificate self link, and certificate domain name.

### D.2. **GSecret Manager**
- **File**: `modules/security/gsecret-manager/gsecret-manager.tf`
  - Creates a GCP secret.
  - Configures the secret with a specific secret value.

- **Variables**: `modules/security/gsecret-manager/variables.tf`
  - Defines naming standards and secret arguments.

- **Outputs**: `modules/security/gsecret-manager/outputs.tf`
  - Provides outputs for the secret name, secret self link, and secret value.
## Deployment

### How to Deploy

1. **Initialize Terraform**:
   Navigate to the `deployment` directory and run:
   ```bash
   terraform init
   ```

2. **Plan Deployment**:
   Review the changes that will be made by Terraform:
   ```bash
   terraform plan
   ```

3. **Apply Changes**:
   Deploy the infrastructure:
   ```bash
   terraform apply
   ```
   Confirm the deployment by typing `yes` when prompted.

4. **Destroy Infrastructure (Optional)**:
   If you need to tear down the infrastructure:
   ```bash
   terraform destroy
   ```
   Confirm the destruction by typing `yes` when prompted.

- **Main Configuration**: `cloud-deployment/main.tf`
  - Uses the above modules to deploy GCP resources.

- **Providers**: `cloud-deployment/providers.tf`
  - Sets up the GCP provider with specific credentials, project, and region.

- **Providers**: `cloud-deployment/outputs.tf`
  - Provides outputs for the deployed infrastructure.
---

This README provides an overview of the Terraform configurations in the `infrastructure/gcp` directory. For detailed configurations and customizations, refer to the respective Terraform files within each module.

---