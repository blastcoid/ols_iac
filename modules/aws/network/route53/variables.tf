# AWS Settings
variable "region" {
  type        = string
  description = "The AWS region where resources will be deployed. This is used to define the AWS region for the provider and any regional resources. Default is 'us-west-2'."
  default     = "us-west-2"
}

variable "standard" {
  type        = map(string)
  description = "A map containing elements that form the standard naming convention for resources. Typically includes 'unit', 'env', 'code', 'feature', and possibly 'sub'."
}

# Route53 arguments
variable "route53_zone_name" {
  type        = string
  description = "The domain name for the Route53 hosted zone. This will be fully qualified, for example 'example.com.'"
}

variable "route53_force_destroy" {
  type        = bool
  description = "A boolean flag indicating whether to destroy all records in the zone and delete the zone itself when destroying the resource. Default is false."
  default     = false
}
