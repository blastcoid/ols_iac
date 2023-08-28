# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "unit" {
  type        = string
  description = "The business unit code representing the organizational unit."
}

variable "env" {
  type        = string
  description = "The environment stage (e.g., dev, prod) where the infrastructure will be deployed."
}

variable "code" {
  type        = string
  description = "The service domain code representing the specific service or application."
}

variable "feature" {
  type        = string
  description = "The specific feature or component of the AWS service being configured."
}

# GKE Arguments
variable "issue_client_certificate" {
  type        = bool
  description = "Whether to issue a client certificate for authenticating to the cluster."
}

variable "vpc_self_link" {
  type        = string
  description = "The self-link URL of the VPC where the cluster will be created."
}

variable "subnet_self_link" {
  type        = string
  description = "The self-link URL of the subnet where the cluster will be created."
}

variable "private_cluster_config" {
  type = map(object({
    enable_private_endpoint = bool   # Whether to enable the private endpoint for the cluster's control plane.
    enable_private_nodes    = bool   # Whether to enable private nodes for the cluster.
    master_ipv4_cidr_block  = string # The CIDR block for the master's private IP address.
  }))
  description = "Configuration for enabling private endpoints and nodes within the cluster."
}

variable "enable_autopilot" {
  type        = bool
  description = "Whether to enable GKE Autopilot, a fully managed Kubernetes service."
}

variable "cluster_autoscaling" {
  type = object({
    enabled = bool
    resource_limits = map(object({
      minimum = number # The minimum number of resources to allocate.
      maximum = number # The maximum number of resources to allocate.
    }))
  })
  description = "Configuration for enabling cluster autoscaling, including resource limits for CPU and memory."
}

variable "binary_authorization" {
  type = object({
    evaluation_mode = string
  })
  description = "Configuration for Binary Authorization, which ensures only trusted container images are deployed."
}

variable "network_policy" {
  type = object({
    enabled  = bool   # Whether to enable network policies.
    provider = string # The network policy provider to use e.g Calico, Cilium, etc.
  })
  description = "Configuration for network policies, which control communication between Pods."
}

variable "datapath_provider" {
  type        = string
  description = "The provider for the datapath, which controls how data is routed within the cluster."
  default     = null
}

variable "master_authorized_networks_config" {
  type = object({
    cidr_blocks = object({
      cidr_block   = string # The CIDR block to allow access from.
      display_name = string # The display name for the CIDR block.
    })
    gcp_public_cidrs_access_enabled = bool # Whether to allow access from GCP public IP addresses.
  })
  description = "Configuration for master authorized networks, which control access to the cluster's master endpoint."
}

variable "dns_config" {
  type = map(object({
    cluster_dns        = string # The DNS provider to use e.g. Cloud DNS, Cloud DNS Private, etc.
    cluster_dns_scope  = string # The scope of the DNS provider e.g. VPC Scope, Private Scope, etc.
    cluster_dns_domain = string # The domain name for the cluster.
  }))
  description = "Configuration for DNS within the cluster, including DNS scope and domain settings."
}

# GKE Node Pool Arguments
variable "pods_secondary_range_name" {
  type        = string
  description = "The name of the secondary IP range for Pods in the cluster."
}

variable "services_secondary_range_name" {
  type        = string
  description = "The name of the secondary IP range for Services in the cluster."
}

variable "node_config" {
  description = "Configuration for on-demand and spot nodes, including machine type, disk size, and other settings."
  type = map(object({
    is_spot         = bool         # Whether to use spot instances for the node pool e.g true or false.
    node_count      = number       # The number of nodes to create in the node pool e.g. 1.
    machine_type    = map(string)  # The machine type to use for the node pool e.g. e2-medium, n1-standard-2, etc.
    disk_size_gb    = number       # The size of the disk attached to each node e.g. 20.
    disk_type       = list(string) # The type of disk attached to each node e.g. pd-standard, pd-ssd.
    service_account = string       # The service account to use for the node pool
    oauth_scopes    = list(string) # The OAuth scopes to use for the node pool e.g. https://www.googleapis.com/auth/cloud-platform.
    tags            = list(string)
    shielded_instance_config = object({  # Shielded Instance Config
      enable_secure_boot          = bool # Whether to enable secure boot for the node pool.
      enable_integrity_monitoring = bool # Whether to enable integrity monitoring for the node pool.
    })
  }))
}

variable "autoscaling" {
  description = "Configuration for autoscaling, including minimum and maximum number of nodes."
  type = map(object({
    min_node_count  = optional(number) # The minimum number of nodes to allocate.
    max_node_count  = optional(number) # The maximum number of nodes to allocate.
    location_policy = optional(string) # Location policy specifies the algorithm used when scaling-up the node pool
  }))

}

variable "node_management" {
  description = "Configuration for node management, including auto-repair and auto-upgrade settings."
  type = object({
    auto_repair  = bool # Whether to enable auto-repair for the node pool.
    auto_upgrade = bool # Whether to enable auto-upgrade for the node pool.
  })
}
