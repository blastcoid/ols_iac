# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
  default     = "asia-southeast2"
}

variable "unit" {
  type        = string
  description = "Business unit code."
  default     = "ols"
}

variable "env" {
  type        = string
  description = "Stage environment where the infrastructure will be deployed."
}

# VPC naming standard
variable "code" {
  type        = list(string)
  description = "Service domain code."
  default     = ["network", "compute", "security", "helm", "db"]
}

# Features
variable "vpc_feature" {
  type        = list(string)
  description = "VPC Feature names"
  default     = ["vpc-main", "vpc-subnet", "vpc-router", "vpc-address", "vpc-nat", "vpc-allow"]
}

variable "dns_feature" {
  type        = list(string)
  description = "Cloud DNS Feature names"
  default     = ["dns-blast"]
}

variable "gke_feature" {
  type        = string
  description = "Google Kubernetes Engine Feature names"
  default     = "gke-main"
}

variable "gce_feature" {
  type        = list(string)
  description = "Google Kubernetes Engine Feature names"
  default     = ["atlantis"]
}

variable "helm_feature" {
  type        = list(string)
  description = "Google Kubernetes Engine Feature names"
  default     = ["external-dns", "nginx", "cert-manager", "argocd"]
}

variable "db_feature" {
  type        = list(string)
  description = "Google Container Registry Feature names"
  default     = ["mongo", "redis"]
}

# tfvars
variable "secrets_ciphertext" {
  description = "List of secrets ciphertext"
}