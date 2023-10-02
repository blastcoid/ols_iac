# Naming Standard
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
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

variable "github_repo" {
  type        = string
  description = "The name of the GitHub repository where the code is stored."
}

variable "github_owner" {
  type        = string
  description = "The name of the GitHub organization where the code is stored."
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