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

variable "account_id" {
  type        = string
  description = "The AWS account ID."
}

#EKS arguments
variable "override_eks_name" {
  type        = string
  description = "Override the EKS cluster name"
  default     = null
}

variable "cluster_version" {
  type        = string
  description = "EKS Cluster version"
}

variable "vpc_config" {
  type = object({
    subnet_ids              = list(string)
    security_group_ids      = optional(list(string), null)
    public_access_cidrs     = optional(list(string), null)
    endpoint_private_access = optional(bool, true)
    endpoint_public_access  = optional(bool, true)
  })
  description = "VPC configuration for the cluster"
}

variable "vpc_id" {
  type        = string
  description = "The VPC to use for the cluster security group"
}

variable "key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encryption"
  default     = null
}

# EKS Node Group arguments
variable "node_config" {
  description = "Configuration for EKS node groups"
  type = map(object({
    instance_type = map(string)
    # Not supported by EKS Managed Node Groups
    # instance_market_options = object({
    #   market_type = string
    #   spot_options = object({
    #     block_duration_minutes         = number
    #     instance_interruption_behavior = string
    #     max_price                      = string
    #     spot_instance_type             = string
    #     valid_until                    = string
    #   })
    # })
    capacity_type = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    key_name = string
    ami_type = string
    # iam_instance_profile = object({
    #   arn  = string
    #   name = string
    # })
    # block_device_mappings = object({
    #   device_name = string
    #   ebs = object({
    #     volume_size           = number
    #     volume_type           = string
    #     delete_on_termination = bool
    #     encrypted             = bool
    #     kms_key_id            = string
    #   })
    # })
    subnet_ids = list(string)
  }))
}

# EKS Fargate Profile arguments
variable "fargate_selectors" {
  type        = list(any)
  description = "Fargate Profile selectors"
  default     = []
}

# EKS KMS Grant arguments

variable "kms_grant_operations" {
  type        = list(string)
  description = "KMS Grant Operations for cluster and node"
  default     = []
}

# EKS OIDC Provider arguments

variable "oidc_provider" {
  type = object({
    client_id_list                = list(string)
    issuer_url                    = string
    identity_provider_config_name = string
    groups_claim                  = optional(string)
    groups_prefix                 = optional(string)
    required_claims               = optional(map(string))
    username_claim                = optional(string)
    username_prefix               = optional(string)
  })
  description = "OIDC External Provider configuration for EKS"
  default     = null
}


# EKS Addons arguments
variable "cluster_addons_before_nodegroup" {
  description = "Map of cluster addon configurations to enable for the cluster before nodegroup creation. Addon name can be the map keys or set with `name`"
  type = map(object({
    most_recent                 = bool
    version                     = optional(string, null)
    resolve_conflicts_on_create = optional(string, null)
    resolve_conflicts_on_update = optional(string, null)
    configuration_values        = optional(string, null)
    service_account_role_arn    = optional(string, null)
  }))
  default = {}
}

variable "cluster_addons_after_nodegroup" {
  description = "Map of cluster addon configurations to enable for the cluster after nodegroup creation. Addon name can be the map keys or set with `name`"
  type = map(object({
    most_recent                 = bool
    version                     = optional(string, null)
    resolve_conflicts_on_create = optional(string, null)
    resolve_conflicts_on_update = optional(string, null)
    configuration_values        = optional(string, null)
    service_account_role_arn    = optional(string, null)
  }))
  default = {}
}


# Security Group arguments

## Cluster
variable "eks_cluster_sg_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), null)
    security_group_id        = optional(string, null)
    source_security_group_id = optional(string, null)
    self                     = optional(bool, null)
    description              = optional(string, null)
  }))
  description = "EKS Cluster Security Group Rules"
}

## Node Group

variable "eks_ng_sg_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), null)
    security_group_id        = optional(string, null)
    source_security_group_id = optional(string, null)
    self                     = optional(bool, null)
    description              = optional(string, null)
  }))
  description = "EKS Node Group Security Group Rules"
}

## ALB
variable "eks_alb_sg_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), null)
    security_group_id        = optional(string, null)
    source_security_group_id = optional(string, null)
    self                     = optional(bool, null)
    description              = optional(string, null)
  }))
  description = "ALB Security Group Rules"
}

## VPC CNI
variable "eks_vpc_cni_sg_ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    security_group_id        = optional(string, null)
    cidr_blocks              = optional(list(string), null)
    source_security_group_id = optional(string, null)
    self                     = optional(bool, null)
    description              = optional(string, null)
  }))
  description = "VPC CNI Security Group Rules"
  default     = []
}

# AWS Auth Configmap arguments
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
