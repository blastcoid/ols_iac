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

variable "code" {
  type        = string
  description = "Service domain code."
  default     = "helm"
}

variable "feature" {
  type        = string
  description = "Feature names"
  default     = "external-dns"
}
