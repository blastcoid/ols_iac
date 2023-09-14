# AWS Settings
variable "region" {
  type        = string
  description = "AWS region"
}

variable "standard" {
  type        = map(string)
  description = "A map containing standard naming convention variables for resources."
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

# S3 arguments
variable "force_destroy" {
  type        = bool
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "object_lock_enabled" {
  type        = bool
  description = "A boolean that indicates whether this bucket has Object Lock enabled. Object Lock can only be enabled at the time the bucket is created."
  default     = false
}

variable "expected_bucket_owner" {
  type        = string
  description = "The account ID of the expected bucket owner"
  default     = null
}

variable "bucket_policy" {
  type        = string
  description = "A valid bucket policy JSON document from data source"
  default     = null
}

variable "bucket_acl" {
  type        = string
  description = "The canned ACL to apply. Defaults to 'private'."
  default     = null
}

variable "bucket_accelerate_status" {
  type        = string
  description = "The Accelerate Configuration associated with this bucket. Valid values are Enabled and Suspended. Defaults to Suspended."
  default     = null
}

variable "bucket_object_ownership" {
  type        = string
  description = "The Object Ownership to be applied to all objects within the bucket. Valid values are BucketOwnerPreferred and ObjectWriter. Defaults to BucketOwnerPreferred."
  default     = null
}

variable "cors_rules" {
  type = map(object({
    allowed_methods = list(string)
    allowed_origins = list(string)
    allowed_headers = optional(list(string))
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  description = "A list of maps defining CORS configuration rules. These rules must contain allowed_headers, allowed_methods, allowed_origins, expose_headers, and max_age_seconds."
  default     = {}
}

variable "public_access_block" {
  type = object({
    block_public_acls       = optional(bool)
    block_public_policy     = optional(bool)
    ignore_public_acls      = optional(bool)
    restrict_public_buckets = optional(bool)
  })
  description = "A object defining the public access block configuration for this bucket. This map must contain block_public_acls, block_public_policy, ignore_public_acls, and restrict_public_buckets."
  default     = null
}

variable "server_side_encryption" {
  type = object({
    sse_algorithm      = string
    kms_master_key_id  = optional(string)
    bucket_key_enabled = optional(bool)
  })
  description = "A object defining the server side encryption configuration for this bucket. This map must contain sse_algorithm, kms_master_key_id, and bucket_key_enabled."
  default     = null
}

variable "versioning" {
  type = object({
    status     = string
    mfa_delete = string
  })
  description = "A object defining the versioning configuration for this bucket. This map must contain status and mfa_delete."
  default     = null
}

variable "versioning_mfa" {
  type        = string
  description = "Concatenation of the authentication device's serial number, a space, and the value that is displayed on your authentication device."
  default     = null
}

variable "website" {
  type = object({
    index_document = optional(object({
      suffix = string
    }))
    error_document = optional(object({
      key = string
    }))
    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string)
    }))
    routing_rule = optional(object({
      condition = object({
        http_error_code_returned_equals = optional(number)
        key_prefix_equals               = optional(string)
      })
      redirect = object({
        host_name               = optional(string)
        http_redirect_code      = optional(number)
        protocol                = optional(string)
        replace_key_prefix_with = optional(string)
        replace_key_with        = optional(string)
      })
    }))
    routing_rules = optional(string)
  })
  description = "A object defining the website configuration for this bucket. This map must contain index_document, error_document, redirect_all_requests_to, and routing_rules."
  default     = null
}
