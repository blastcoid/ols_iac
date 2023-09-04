#Naming Standard
variable "region" {
  type        = string
  description = "GCP region"
}

variable "env" {
  type        = string
  description = "Stage environment"
}

# Artifact Registry arguments
variable "repository_id" {
  type        = string
  description = "Artifact Registry repository ID"
}

variable "repository_format" {
  type        = string
  description = "Artifact Registry repository format"
}

variable "repository_mode" {
  type        = string
  description = "Artifact Registry repository mode"
}

variable "cleanup_policy_dry_run" {
  type        = bool
  description = "Artifact Registry repository cleanup policy dry run"
  default     = null
}

variable "cleanup_policies" {
  type = map(object({
    action = optional(string)
    condition = optional(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string))
      version_name_prefixes = optional(list(string))
      package_name_prefixes = optional(list(string))
      older_than            = optional(string)
      newer_than            = optional(string)
    }))
    most_recent_versions = optional(object({
      package_name_prefixes = optional(list(string))
      keep_count            = optional(number)
    }))
  }))
  description = "Artifact Registry repository cleanup policies"
  default     = {}
}
