# GCP Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "env" {
  type        = string
  description = "Stage environment where the infrastructure will be deployed."
}

# vpc arguments
variable "vpc_name" {
  type        = string
  description = "The name of the VPC."
}

variable "auto_create_subnetworks" {
  type        = bool
  description = "Whether to create subnetworks in the VPC."
  default     = true
}

# subnet arguments
variable "subnet_name" {
  type        = string
  description = "The name of the subnetwork."
}

variable "ip_cidr_range" {
  type        = map(string)
  description = "The primary IP CIDR range of the subnetwork based on the environment."
}

variable "secondary_ip_range" {
  description = "Secondary IP ranges for GKE pods and services based on the environment."
  type = map(list(object({
    range_name    = string
    ip_cidr_range = string
  })))
}

# router arguments
variable "router_name" {
  type        = string
  description = "The name of the router."
}

variable "address_name" {
  type        = string
  description = "The name of the external IP address."
}

# nat arguments
variable "nat_name" {
  type        = string
  description = "The name of the NAT."
}

variable "nat_ip_allocate_option" {
  type        = string
  description = "The way NAT IPs should be allocated. Valid values are AUTO_ONLY, MANUAL_ONLY or AUTO_ONLY."
}

variable "source_subnetwork_ip_ranges_to_nat" {
  type        = string
  description = "The way NAT IPs should be allocated. Valid values are LIST_OF_SUBNETWORKS or ALL_SUBNETWORKS_ALL_IP_RANGES."
}

variable "subnetworks" {
  type = list(object({
    name                    = string
    source_ip_ranges_to_nat = list(string)
  }))
  description = "List of subnetworks to configure NAT for."
  default     = []
}

# firewall arguments
variable "firewall_name" {
  type        = string
  description = "The name of the firewall rule."
}

variable "vpc_firewall_rules" {
  description = "Map of firewall rules to be applied to the VPC."
  type = map(object({
    name        = string
    description = string
    direction   = string
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    source_ranges = map(list(string))
    priority      = number
  }))
  default = {}
}
