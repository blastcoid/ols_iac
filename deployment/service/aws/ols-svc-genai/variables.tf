# AWS Settings
variable "region" {
  type        = string
  description = "AWS region"
}

variable "unit" {
  type        = string
  description = "Business unit code"
  default     = "ols"
}

variable "env" {
  type        = string
  description = "Stage environment"
}

# GitHub Settings
variable "github_owner" {
  type        = string
  description = "GitHub owner"
}

# Configs and Secrets for AWS SSM Parameter Store
variable "configs" {
  type        = map(string)
  description = "Service configmaps"
}

variable "secrets_ciphertext" {
  type        = map(string)
  description = "Service secrets in ciphertext"
}

# Load github secret ciphertext
# variable "github_secret_ciphertext" {
#   type        = string
#   description = "GitHub webhook secret"
# }

# variable "github_action_secrets_ciphertext" {
#   type        = map(string)
#   description = "GitHub action secrets"
# }
