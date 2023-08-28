# project arguments
variable "org_id" {
  description = "Organization ID"
  type        = string
  default     = null
}

# variable "auto_create_network" {
#   description = "Auto create network"
#   type        = bool
#   default     = true
# }

variable "project_id" {
  description = "Project ID"
  type        = string
}

# variable "policy_data" {
#   description = "Policy data"
#   type        = string
#   default     = null
# }


# custom roles arguments
variable "custom_roles" {
  description = "Project custom roles"
  type        = map(object({
    title       = string
    permissions = list(string)
  }))
  default     = {}
}

# services arguments
variable "services" {
  description = "Project services"
  type        = map(string)
  default     = {}
}

variable "disable_dependent_services" {
  description = "Disable dependent services"
  type        = bool
  default     = true
}