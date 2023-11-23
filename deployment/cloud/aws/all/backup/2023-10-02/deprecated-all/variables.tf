# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
  default     = "us-west-1"
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

# Config & Secrets
variable "configs" {
  type        = map(string)
  description = "A map containing config variables for resources."
}

variable "secrets_ciphertext" {
  type        = map(string)
  description = "The encrypted secret value."
  # sensitive   = true
}
