# Naming Standard
variable "unit" {
  type        = string
  description = "Business unit code."
  default     = "ols"
}

variable "env" {
  type        = string
  description = "Stage environment where the infrastructure will be deployed."
}

variable "code" {
  type        = string
  description = "Service domain code."
  default     = "network"
}

variable "feature" {
  type        = list(string)
  description = "Feature names"
  default     = ["vpc-main", "vpc-subnet", "vpc-router", "vpc-address", "vpc-nat", "vpc-allow"]
}
