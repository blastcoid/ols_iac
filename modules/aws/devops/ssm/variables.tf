# AWS Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "A map containing standard naming convention variables for resources."
}

# SSM arguments - required
variable "configs" {
  type        = map(string)
  description = "A map containing config variables for resources."
  default     = {}
}

variable "secrets" {
  type        = map(string)
  description = "A map containing secret variables for resources."
  default     = {}
  # sensitive   = true
}

# SSM arguments - optional
variable "data_type" {
  type        = string
  description = "The type of the parameter."
  default     = "text"
}

variable "allowed_pattern" {
  type        = string
  description = "A regular expression used to validate the parameter value."
  default     = null
}

variable "key_id" {
  type        = string
  description = "The KMS key ID or ARN to use to encrypt the parameter value."
  default     = null
}

variable "tier" {
  type        = string
  description = "The tier of the parameter."
  default     = "Standard"
}

