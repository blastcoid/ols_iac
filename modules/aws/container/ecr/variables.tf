# AWS Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "A map containing standard naming convention variables for resources."
}

# ECR arguments
variable "namespaces" {
  type        = list(string)
  description = "A list of namespaces to create in the ECR repository."
}

variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE"
}

variable "scan_on_push" {
  type        = bool
  description = "Whether or not to scan images on push."
}

variable "force_delete" {
  type        = bool
  description = "if true delete the repository even if it contains images"
}

variable "encryption_configuration" {
  type = object({
    encryption_type = string
    kms_key         = optional(string)
  })
  description = "The encryption configuration for the repository."
  default = {
    encryption_type = "AES256"
    kms_key         = null
  }
}

# ECR Lifecycle Policy
variable "ecr_lifecycle_policy" {
  type        = string
  description = "The policy document. This is a JSON formatted string."
}

# ECR Registry Scanning Configuration
variable "scan_type" {
  type        = string
  description = "The type of scan to run. This can be either 'SCHEDULED' or 'ON_PUSH'."
}
