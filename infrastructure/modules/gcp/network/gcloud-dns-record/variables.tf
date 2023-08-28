variable "subdomain" {
  description = "subdomain name"
  type        = string
}

variable "dns_zone_name" {
  description = "dns zone name"
  type        = string
}

variable "dns_name" {
  description = "dns name"
  type        = string
}

variable "record_type" {
  description = "record type"
  type        = string
}

variable "ttl" {
  description = "ttl"
  type        = number
}

variable "rrdatas" {
  description = "rrdatas"
  type        = list(string)
}