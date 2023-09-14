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
variable "codebuild_policy" {
  type = string
  description = "The policy document of the CodeBuild role from data source"
}

variable "kms_grant_operations" {
  type        = list(string)
  description = "The list of operations to grant on the KMS key"
  default     = []
}

# CodeBuild arguments - required

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#artifacts
variable "artifacts" {
  type = object({
    type                   = string
    artifact_identifier    = optional(string)
    bucket_owner_access    = optional(string)
    name                   = optional(string)
    override_artifact_name = optional(bool)
    location               = optional(string)
    namespace_type         = optional(string)
    packaging              = optional(string)
    path                   = optional(string)
    encryption_disabled    = optional(bool)
  })
  description = "Information about the build output artifacts for the build project."
  default = {
    type                   = "NO_ARTIFACTS"
    artifact_identifier    = null
    name                   = null
    override_artifact_name = null
    location               = null
    namespace_type         = null
    packaging              = null
    path                   = null
    encryption_disabled    = false
    # override_artifact_name = false
    artifact_identifier = null
  }
}

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#environment
variable "environment" {
  type = object({
    certificate  = optional(string)
    compute_type = string
    environment_variables = list(object({
      name  = string
      value = string
      type  = optional(string)
    }))
    image           = string
    type            = string
    privileged_mode = bool
  })
  description = "Information about the build environment for the build project."
}

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#source
variable "sources" {
  type = object({
    type            = string
    buildspec       = optional(string)
    git_clone_depth = optional(number)
    git_submodules_config = optional(object({
      fetch_submodules = optional(bool)
    }))
    build_status_config = optional(object({
      context    = optional(string)
      target_url = optional(string)
    }))
    insecure_ssl        = optional(bool)
    location            = optional(string)
    report_build_status = optional(bool)
  })
  description = "Information about the build input source code for the build project."
  default = {
    type                  = "NO_SOURCE"
    buildspec             = null
    git_clone_depth       = null
    git_submodules_config = null
    build_status_config   = null
    insecure_ssl          = null
    location              = null
    report_build_status   = null
  }
  validation {
    condition     = var.sources.type == "NO_SOURCE" || var.sources.type == "CODECOMMIT" || var.sources.type == "CODEPIPELINE" || var.sources.type == "GITHUB" || var.sources.type == "S3" || var.sources.type == "BITBUCKET"
    error_message = "source.type must be one of NO_SOURCE, CODECOMMIT, CODEPIPELINE, GITHUB, S3, or BITBUCKET"
  }
}

# CodeBuild arguments - optional

variable "build_timeout" {
  type        = number
  description = "The number of minutes after which AWS CodeBuild stops the build if it's not complete. Must be between 5 and 480 minutes."
  default     = 60
}

variable "badge_enabled" {
  type        = bool
  description = "Generates a publicly-accessible URL for the projects build badge. Available as badge_url attribute when enabled."
  default     = null
}

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#cache
variable "cache" {
  type = object({
    type     = string
    modes    = optional(list(string))
    location = optional(string)
  })
  description = "Information about the cache storage for the build project."
  default     = null
}

variable "concurrent_build_limit" {
  type        = number
  description = "The maximum number of concurrent builds that are allowed for this project."
  default     = null
}

variable "file_system_locations" {
  type = object({
    type        = optional(string)
    location    = optional(string)
    mount_point = optional(string)
    identifier  = optional(string)
  })
  description = "A list of one or more file system locations that are used in a build."
  default     = null
}

variable "encryption_key" {
  type        = string
  description = "The AWS Key Management Service (AWS KMS) customer master key (CMK) to be used for encrypting the build output artifacts."
  default     = null
}

variable "logs_config" {
  type = object({
    cloudwatch_logs = optional(object({
      status      = optional(string)
      group_name  = optional(string)
      stream_name = optional(string)
    }))
    s3_logs = optional(object({
      status              = optional(string)
      location            = optional(string)
      encryption_disabled = optional(bool)
    }))
  })
  description = "Information about logs for the build project. A project can create logs in Amazon CloudWatch Logs, an S3 bucket, or both."
  default     = null
}

variable "project_visibility" {
  type        = string
  description = "The public visibility for this build project. Possible values are PUBLIC, PRIVATE."
  default     = "PRIVATE"
}

variable "resource_access_role" {
  type        = string
  description = "The ARN of the IAM role that enables CodeBuild to access the CloudWatch Logs and Amazon S3 artifacts for the project's builds."
  default     = null
}

variable "queued_timeout" {
  type        = number
  description = "The number of minutes a build is allowed to be queued before it times out."
  default     = 480
}

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#secondary_artifacts
variable "secondary_artifacts" {
  type = object({
    type                   = string
    artifact_identifier    = string
    bucket_owner_access    = optional(string)
    name                   = optional(string)
    override_artifact_name = optional(bool)
    location               = optional(string)
    namespace_type         = optional(string)
    packaging              = optional(string)
    path                   = optional(string)
    encryption_disabled    = optional(bool)
  })
  description = "Information about the build output artifacts for the build project."
  default     = null
}

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#secondary_sources
variable "secondary_sources" {
  type = object({
    type              = string
    source_identifier = string
    buildspec         = optional(string)
    git_clone_depth   = optional(number)
    git_submodules_config = optional(object({
      fetch_submodules = optional(bool)
    }))
    build_status_config = optional(object({
      context    = optional(string)
      target_url = optional(string)
    }))
    insecure_ssl        = optional(bool)
    location            = optional(string)
    report_build_status = optional(bool)
  })
  description = "Information about the build input source code for the build project."
  default     = null
}

variable "source_version" {
  type        = string
  description = "A version of the build input to be built for this project. If not specified, the latest version is used."
  default     = null
}

# ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project#vpc_config
variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    vpc_id             = string
    security_group_ids = optional(list(string))
  })
  description = "Information about the VPC configuration that AWS CodeBuild accesses."
  default     = null
}
