# Naming Standard
variable "region" {
  type        = string
  description = "The Google Cloud region where resources will be created."
}

variable "unit" {
  type        = string
  description = "Business unit code representing the organizational entity within the company."
}

variable "env" {
  type        = string
  description = "Environment stage (e.g., dev, prod) where the infrastructure will be deployed."
}

variable "code" {
  type        = string
  description = "Service domain code representing the specific service or application."
}

variable "feature" {
  type        = list(string)
  description = "Features name of the service or application."
}

# Service Account Arguments
variable "project_id" {
  type        = string
  description = "The Google Cloud Project ID where resources will be managed."
}

variable "service_account_role" {
  type        = string
  description = "IAM role to be assigned to the service account."
}

# Google Cloud Compute Arguments
variable "zone" {
  type        = string
  description = "The Google Cloud zone within the region for resource placement."
}

variable "linux_user" {
  type        = string
  description = "linux user for accessing the virtual machine instances."
}

variable "machine_type" {
  type        = string
  description = "The machine type (e.g., n1-standard-1) for the virtual machine instances."
}

variable "disk_size" {
  type        = number
  description = "The size of the persistent disk, in GB."
}

variable "disk_type" {
  type        = string
  description = "The type of persistent disk to use (e.g., pd-standard, pd-ssd)."
}

variable "tags" {
  type        = list(string)
  description = "Tags to be applied to resources for identification and grouping."
}

variable "image" {
  type        = string
  description = "The source image for the virtual machine instances."
}

variable "network_self_link" {
  type        = string
  description = "The self-link URL of the network to which the instances will be connected."
}

variable "subnet_self_link" {
  type        = string
  description = "The self-link URL of the subnet within the network."
}

variable "is_public" {
  type        = bool
  description = "Boolean flag to control whether instances are assigned a public IP address."
}

variable "access_config" {
  type        = map(map(string))
  description = "Configuration for accessing the instances, including public IP assignment."
}

variable "run_ansible" {
  type        = bool
  description = "Flag to control whether to run the Ansible playbook as part of the provisioning process."
}

variable "ansible_vars" {
  type        = map(string)
  description = "Variables to be passed to the Ansible playbook."
}

variable "ansible_tags" {
  type        = list(string)
  description = "Tags to be used to control which Ansible tasks are run."
}

variable "ansible_skip_tags" {
  type        = list(string)
  description = "Tags to be used to control which Ansible tasks are skipped."
}

# DNS Record Arguments
variable "create_dns_record" {
  type        = bool
  description = "Flag to control whether to create a DNS record for the instances."
}

variable "dns_config" {
  description = "Configuration for the DNS record, including domain name and record type."
}

# Google Cloud Firewall Arguments
variable "firewall_rules" {
  type = map(object({
    protocol = string
    ports    = list(number)
  }))
  description = "Map of firewall rules to apply, including protocol and port range."
}

variable "source_ranges" {
  type        = list(string)
  description = "List of source IP address ranges that will be allowed to connect to the instances."
}

variable "priority" {
  type        = number
  description = "Priority of the firewall rules, with lower numbers indicating higher priority."
}

variable "target_tags" {
  type        = list(string)
  description = "Tags for the target resources to which the firewall rules will be applied."
}
