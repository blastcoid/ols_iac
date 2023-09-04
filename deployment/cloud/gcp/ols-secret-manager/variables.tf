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
  default     = "security"
}

variable "feature" {
  type        = string
  description = "Feature names"
  default     = "secret-manager-github-oauth-client-secret-argocd"
}

# Load encrypted secrets
variable "secrets_ciphertext" {
  type        = map(string)
  description = "Encrypted secrets"
}
