# AWS Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
}

variable "standard" {
  type        = map(string)
  description = "A map containing standard naming convention variables for resources."
}

# Codepipeline role arguments - required
variable "codepipeline_policy" {
  type        = string
  description = "The policy document of the CodeBuild role from data source"
}

variable "kms_grant_operations" {
  type        = list(string)
  description = "The list of operations to grant on the KMS key"
  default     = []
}

# Codepipeline arguments - required
variable "artifact_store" {
  type = object({
    location = string
    type     = string
    encryption_key = optional(object({
      id   = string
      type = string
    }))
    region = optional(string)
  })
}

variable "stages" {
  type = list(object({
    name = string
    action = object({
      category         = string
      owner            = string
      name             = string
      provider         = string
      version          = string
      input_artifacts  = optional(list(string))
      output_artifacts = optional(list(string))
      configuration    = optional(map(string))
      role_arn         = optional(string)
      run_order        = optional(number)
      region           = optional(string)
      namespace        = optional(string)
    })
  }))
}

# Webhook arguments - optional

variable "webhook_authentication" {
  type        = string
  description = "The type of authentication used to validate incoming requests to the webhook. Valid values are GITHUB_HMAC, IP, and UNAUTHENTICATED."
  default     = "GITHUB_HMAC"
}

variable "webhook_target_action" {
  type        = string
  description = "The name of the action in a pipeline you want to connect to the webhook. The action must be from the source (first) stage of the pipeline."
  default     = "Source"
}

variable "authentication_configuration" {
  type = object({
    secret_token     = optional(string)
    allowed_ip_range = optional(string)
  })
  description = "The property used to configure acceptance of webhooks in an IP address range. Required if authentication is IP."
  default = {
    secret_token     = null
    allowed_ip_range = null
  }
}

variable "webhook_filter" {
  type = object({
    json_path    = string
    match_equals = string
  })
  description = "The property used to configure filtering of webhooks. Required if authentication is IP."
  default     = null
}

variable "github_repository_name" {
  type        = string
  description = "The name of the GitHub repository."
}

variable "webhook_events" {
  type        = list(string)
  description = "A list of event types to be used for filtering. If no events are listed, the webhook is triggered for all event types."
  default     = []
}
