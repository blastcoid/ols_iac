# Github membership arguments
variable "username" {
  type        = string
  description = "github username"
}

variable "organization_role" {
  type        = string
  description = "github membership role"
}


# Github team membership arguments
variable "teams" {
  type        = list(map(string))
  description = "github teams"
}

# Github repository collaborator arguments
variable "repositories_collaborator" {
  type        = map(string)
  description = "github repositories name and permission"
}
