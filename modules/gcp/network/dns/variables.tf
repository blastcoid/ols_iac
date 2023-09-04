#Naming Standard
variable "region" {
  type        = string
  description = "GCP region"
}

# cloud dns arguments
variable "zone_name" {
  type        = string
  description = "the zone name to use"
}

variable "zone_dns_name" {
  type        = string
  description = "the dns name to use"
}

variable "zone_description" {
  type        = string
  description = "the zone description to use"
}

variable "zone_force_destroy" {
  type        = bool
  description = "the force destroy to use"
}

variable "zone_visibility" {
  type        = string
  description = "the visibility to use"
  default     = "public"
}

variable "private_visibility_config" {
  type = object({
    networks = object({
      network_url = string
    })
    gke_clusters = object({
      gke_cluster_name = string
    })
  })
  description = "the private visibility config to use"
  default     = null
}
