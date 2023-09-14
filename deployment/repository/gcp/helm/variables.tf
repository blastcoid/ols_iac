# Credentials
# Load github secret ciphertext
variable "github_secret_ciphertext" {
  type        = string
  description = "GitHub webhook secret"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "asia-southeast2"
}

# Naming Standard
variable "unit" {
  type        = string
  description = "Business unit code"
  default     = "ols"
}

variable "env" {
  type        = string
  description = "Stage environment"
}

variable "code" {
  type        = string
  description = "Service domain code"
  default     = "repository"
}

variable "feature" {
  type        = string
  description = "Feature name"
  default     = "helm"
}
