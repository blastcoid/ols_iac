# Local Variables
# ---------------
# Generate a standard naming convention for resources.
locals {
  naming_standard     = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
  svc_naming_standard = "${var.standard.unit}-${var.standard.sub}-${var.standard.name}"
}

# AWS ECR Repository Resource
# ---------------------------
# Creates an AWS ECR repository with:
# - Configurable image tag mutability
# - Image scanning options
# - Optional force delete
# - Dynamic encryption settings
resource "aws_ecr_repository" "repository" {
  count                = length(var.namespaces)
  name                 = var.standard.sub == "svc" && var.standard.name != null ? "${var.namespaces[count.index]}/${local.svc_naming_standard}" : "${var.namespaces[count.index]}/${local.naming_standard}"
  image_tag_mutability = var.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  force_delete = var.force_delete
  dynamic "encryption_configuration" {
    for_each = [var.encryption_configuration]
    content {
      encryption_type = encryption_configuration.value.encryption_type
      kms_key         = encryption_configuration.value.kms_key
    }
  }
  tags = {
    "Name"      = local.naming_standard
    "Unit"      = var.standard.unit
    "Env"       = var.standard.env
    "Code"      = var.standard.code
    "Feature"   = var.standard.feature
    "Sub"       = var.standard.sub
    "Service"   = var.standard.name
    "Namespace" = var.namespaces[count.index]
  }
}

# AWS ECR Lifecycle Policy Resource
# ---------------------------------
# Attaches a lifecycle policy to an ECR repository.
resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  count      = length(var.namespaces)
  repository = aws_ecr_repository.repository[count.index].name
  policy     = var.ecr_lifecycle_policy
}

# AWS ECR Registry Scanning Configuration Resource
# ------------------------------------------------
# Configures image scanning settings, including:
# - Scan type
# - Scan frequency
# - Repository filters
resource "aws_ecr_registry_scanning_configuration" "configuration" {
  scan_type = var.scan_type
  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*${var.namespaces[0]}/${local.svc_naming_standard}*"
      filter_type = "WILDCARD"
    }
  }

  dynamic "rule" {
    for_each = var.scan_type == "ENHANCED" ? [1] : []
    content {
      scan_frequency = "CONTINUOUS_SCAN"
      repository_filter {
        filter      = "*${var.namespaces[0]}/${local.svc_naming_standard}*"
        filter_type = "WILDCARD"
      }
    }
  }
}
