
# GCompute Engine Module for Google Cloud Platform (GCP)

This Terraform module provisions and manages Google Compute Engine instances on GCP, along with associated resources such as SSH keys, service accounts, DNS records, firewall rules, and Ansible playbook execution.

## Features
- **SSH Key Generation**: Creates an RSA private key for SSH access.
- **Service Account Management**: Configures a Google Cloud Service Account with specific IAM roles.
- **Compute Engine Instance Creation**: Provisions Google Compute Engine instances with configurable parameters.
- **DNS Record Management**: Optionally creates DNS records for instances.
- **Firewall Rule Configuration**: Defines and applies firewall rules to instances.
- **Ansible Integration**: Optionally runs an Ansible playbook with support for tags and skip-tags.

## Usage Example
```hcl
module "gcompute_engine" {
  source              = "./gcompute-engine"
  region              = "us-central1"
  unit                = "dev"
  env                 = "test"
  code                = "app1"
  feature             = ["web"]
  project_id          = "my-project-i"
  service_account_role = "roles/editor"
  zone                = "us-central1-a"
  machine_type        = "n1-standard-1"
  disk_size           = 100
  disk_type           = "pd-standard"
  image               = "debian-cloud/debian-9"
  network_self_link   = "global/networks/default"
  subnet_self_link    = "regions/us-central1/subnetworks/default"
  is_public           = true
  run_ansible         = false
}
```

## Input (Variables)

| Name                  | Description                                           | Type          | Default | Required |
|-----------------------|-------------------------------------------------------|---------------|---------|----------|
| `region`              | GCP region                                             | `string`      | -       | Yes      |
| `unit`                | Business unit code                                    | `string`      | -       | Yes      |
| `env`                 | Environment stage                                    | `string`      | -       | Yes      |
| `code`                | Service domain code                                   | `string`      | -       | Yes      |
| `feature`             | Features name of the service                          | `list(string)`| -       | Yes      |
| `project_id`          | Google Cloud Project ID                               | `string`      | -       | Yes      |
| `service_account_role`| IAM role for service account                          | `string`      | -       | Yes      |
| `zone`                | GCP zone                                              | `string`      | -       | Yes      |
| `username`            | Username for VM instances                             | `string`      | -       | Yes      |
| `machine_type`        | Machine type for VM instances                         | `string`      | -       | Yes      |
| `disk_size`           | Disk size in GB                                       | `number`      | -       | Yes      |
| `disk_type`           | Disk type (e.g., pd-standard)                         | `string`      | -       | Yes      |
| `tags`                | Tags for resources                                    | `list(string)`| -       | Yes      |
| `image`               | Source image for VM instances                         | `string`      | -       | Yes      |
| `network_self_link`   | Network self-link URL                                 | `string`      | -       | Yes      |
| `subnet_self_link`    | Subnet self-link URL                                  | `string`      | -       | Yes      |
| `is_public`           | Assign public IP (true/false)                         | `bool`        | -       | Yes      |
| `access_config`       | Access configuration                                  | `map`         | -       | Yes      |
| `run_ansible`         | Run Ansible playbook (true/false)                     | `bool`        | -       | Yes      |
| `ansible_vars`        | Ansible variables                                     | `map(string)` | -       | Yes      |
| `ansible_tags`        | Ansible tags                                          | `list(string)`| -       | Yes      |
| `ansible_skip_tags`   | Ansible skip tags                                     | `list(string)`| -       | Yes      |
| `create_dns_record`   | Create DNS record (true/false)                        | `bool`        | -       | Yes      |
| `dns_config`          | DNS configuration                                     | `map`         | -       | Yes      |
| `firewall_rules`      | Firewall rules                                        | `map`         | -       | Yes      |
| `source_ranges`       | Firewall source ranges                                | `list(string)`| -       | Yes      |
| `priority`            | Firewall priority                                     | `number`      | -       | Yes      |
| `target_tags`         | Firewall target tags                                  | `list(string)`| -       | Yes      |

## Output

| Name          | Description                             |
|---------------|-----------------------------------------|
| `private_key` | Generated private SSH key (sensitive)   |
| `public_ip`   | Public IP address of the instance       |
| `private_ip`  | Private IP address of the instance      |
