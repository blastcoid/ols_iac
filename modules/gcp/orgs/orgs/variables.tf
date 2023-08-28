# organization argumentx

variable "orgs_id" {
  type        = string
  description = "The organization id"
}

variable "custom_roles" {
  description = "Organization custom roles"
  type        = map(object({
    role_id     = string
    title       = string
    permissions = list(string)
  }))
  default     = {}
}

variable "policy_name" {
  description = "Organization policy name"
  type        = string
  default     = null
}

variable "policy_spec" {
  description = "Organization policy spec"
  type        = map(object({
    inherit_from_parent = bool
    reset               = bool
    values              = list(string)
    rule = map(object({
      allow_all = bool
      deny_all  = bool
      condition = list(string)
    }))
  }))
  default     = {}
}

