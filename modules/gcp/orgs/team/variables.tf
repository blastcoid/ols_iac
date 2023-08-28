# Organization folder arguments

variable "divisions" {
  type = map(list(string))
  default = {}
  # default = {
  #   "it"       = ["backend", "frontend", "devops", "qa", "security", "data", "infra", "support"]
  #   "business" = ["sales", "marketing", "finance", "hr", "legal"]
  #   "finance"  = ["accounting", "tax", "audit"]
  # }
}

variable "policy_spec" {}