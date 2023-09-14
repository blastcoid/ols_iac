# AWS Settings
variable "region" {
  type        = string
  description = "The GCP region where resources will be created."
  default     = "us-west-2"
}

variable "standard" {
  type        = map(string)
  description = "The standard naming convention for resources."
}

#EKS arguments
variable "override_eks_name" {
  type        = string
  description = "Override the EKS cluster name"
  default     = null
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
}

variable "vpc_config" {
  type = list(object({
    subnet_ids              = list(string)
    security_group_ids      = list(string)
    public_access_cidrs     = list(string)
    endpoint_private_access = bool
    endpoint_public_access  = bool
  }))
  description = "VPC configuration for the cluster"
}

variable "vpc_id" {
  type        = string
  description = "The VPC to use for the cluster security group"
}

variable "eks_cluster_ingress_rules_cidr_blocks" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "EKS Cluster Ingress Rules CIDR Blocks"
  default     = null
}

variable "eks_cluster_ingress_rules_security_groups" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    security_groups = list(string)
  }))
  description = "EKS Cluster Ingress Rules Security Groups"
  default     = null
}

variable "eks_cluster_egress_rules_cidr_blocks" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "EKS Cluster Egress Rules CIDR Blocks"
  default     = null
}

variable "eks_cluster_egress_rules_security_groups" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    security_groups = list(string)
  }))
  description = "EKS Cluster Egress Rules Security Groups"
  default     = null
}

variable "encryption_config" {
  type = list(object({
    provider   = list(object({
      key_arn = string
    }))
    resources = list(string)
  }))
  description = "Encryption configuration for the cluster"
}

# EKS Node Group arguments
variable "node_config" {
  description = "Configuration for EKS node groups"
  type = map(object({
    instance_type = map(string)
    instance_market_options = object({
      market_type = string
      spot_options = object({
        block_duration_minutes         = number
        instance_interruption_behavior = string
        max_price                      = string
        spot_instance_type             = string
        valid_until                    = string
      })
    })
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    key_name = string
    iam_instance_profile = object({
      arn  = string
      name = string
    })
    block_device_mappings = object({
      device_name = string
      ebs = object({
        volume_size           = number
        volume_type           = string
        delete_on_termination = bool
        encrypted             = bool
        kms_key_id            = string
      })
    })
    subnet_ids = list(string)
  }))
}


variable "eks_node_ingress_rules_cidr_blocks" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "EKS Cluster Ingress Rules CIDR Blocks"
  default     = null
}

variable "eks_node_egress_rules_cidr_blocks" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "EKS Cluster Egress Rules CIDR Blocks"
  default     = null
}
