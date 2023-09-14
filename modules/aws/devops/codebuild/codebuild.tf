locals {
  naming_standard     = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
  svc_naming_standard = "${var.standard.unit}-${var.standard.env}-${var.standard.sub}-${var.standard.name}"
}

resource "aws_codebuild_project" "project" {
  # Required
  name         = var.standard.sub == "svc" && var.standard.name != null ? local.svc_naming_standard : local.naming_standard
  service_role = aws_iam_role.role.arn
  dynamic "artifacts" {
    for_each = [var.artifacts]
    content {
      artifact_identifier    = artifacts.value.artifact_identifier
      bucket_owner_access    = artifacts.value.type == "S3" ? artifacts.value.bucket_owner_access : null
      type                   = artifacts.value.type
      name                   = artifacts.value.type == "S3" ? artifacts.value.name : null
      location               = artifacts.value.type == "S3" ? artifacts.value.location : null
      namespace_type         = artifacts.value.namespace_type
      override_artifact_name = artifacts.value.type == "S3" ? artifacts.value.override_artifact_name : null
      packaging              = artifacts.value.type == "S3" ? artifacts.value.packaging : null
      path                   = artifacts.value.type == "S3" ? artifacts.value.path : null
      encryption_disabled    = artifacts.value.type != "NO_ARTIFACTS" ? artifacts.value.encryption_disabled : null
    }
  }

  dynamic "environment" {
    for_each = [var.environment]
    content {
      compute_type    = environment.value.compute_type
      image           = environment.value.image
      type            = environment.value.type
      privileged_mode = environment.value.privileged_mode

      dynamic "environment_variable" {
        for_each = environment.value.environment_variables
        content {
          name  = environment_variable.value.name
          value = environment_variable.value.value
          type  = environment_variable.value.type
        }
      }
    }
  }

  dynamic "source" {
    for_each = [var.sources]
    content {
      type            = source.value.type
      buildspec       = source.value.buildspec
      insecure_ssl    = source.value.insecure_ssl
      location        = source.value.type == "S3" || source.value.type == "GITHUB" || source.value.type == "BITBUCKET" ? source.value.location : null
      git_clone_depth = source.value.type == "GITHUB" || source.value.type == "CODECOMMIT" ? source.value.git_clone_depth : null

      dynamic "git_submodules_config" {
        for_each = source.value.type == "GITHUB" || source.value.type == "CODECOMMIT" ? [source.value.git_submodules_config] : []
        content {
          fetch_submodules = git_submodules_config.value.fetch_submodules
        }
      }

      dynamic "build_status_config" {
        for_each = source.value.type == "GITHUB" || source.value.type == "BITBUCKET" ? [source.value.build_status_config] : []
        content {
          context    = build_status_config.value.context
          target_url = build_status_config.value.target_url
        }
      }

      report_build_status = source.value.type == "GITHUB" || source.value.type == "BITBUCKET" ? source.value.report_build_status : null
    }
  }
  # Optional
  badge_enabled = var.badge_enabled
  build_timeout = var.build_timeout
  dynamic "cache" {
    for_each = var.cache != null ? [var.cache] : []
    content {
      type     = cache.value.type
      modes    = cache.value.type == "LOCAL" ? cache.value.modes : []
      location = cache.value.type == "S3" ? cache.value.location : null
    }
  }
  concurrent_build_limit = var.concurrent_build_limit
  description            = "CodeBuild project for ${local.naming_standard}"
  dynamic "file_system_locations" {
    for_each = var.file_system_locations != null ? [var.file_system_locations] : []
    content {
      identifier  = file_system_locations.value.identifier
      location    = file_system_locations.value.location
      mount_point = file_system_locations.value.mount_point
      type        = file_system_locations.value.type
    }
  }
  encryption_key = var.encryption_key
  dynamic "logs_config" {
    for_each = var.logs_config != null ? [var.logs_config] : []
    content {
      dynamic "cloudwatch_logs" {
        for_each = logs_config.value.cloudwatch_logs != null ? [logs_config.value.cloudwatch_logs] : []
        content {
          group_name  = cloudwatch_logs.value.group_name
          stream_name = cloudwatch_logs.value.stream_name
          status      = cloudwatch_logs.value.status
        }
      }
      dynamic "s3_logs" {
        for_each = logs_config.value.s3_logs != null ? [logs_config.value.s3_logs] : []
        content {
          encryption_disabled = s3_logs.value.encryption_disabled
          location            = s3_logs.value.location
          status              = s3_logs.value.status
          bucket_owner_access = s3_logs.value.bucket_owner_access
        }
      }
    }
  }
  project_visibility   = var.project_visibility
  resource_access_role = var.resource_access_role
  queued_timeout       = var.queued_timeout
  dynamic "secondary_artifacts" {
    for_each = var.secondary_artifacts != null ? [var.secondary_artifacts] : []
    content {
      type                   = secondary_artifacts.value.type
      artifact_identifier    = secondary_artifacts.value.artifact_identifier
      bucket_owner_access    = secondary_artifacts.value.type == "S3" ? secondary_artifacts.value.bucket_owner_access : null
      name                   = secondary_artifacts.value.type == "S3" ? secondary_artifacts.value.name : null
      override_artifact_name = secondary_artifacts.value.type == "S3" ? secondary_artifacts.value.override_artifact_name : null
      location               = secondary_artifacts.value.type == "S3" ? secondary_artifacts.value.location : null
      namespace_type         = secondary_artifacts.value.namespace_type
      packaging              = secondary_artifacts.value.type == "S3" ? secondary_artifacts.value.packaging : null
      path                   = secondary_artifacts.value.type == "S3" ? secondary_artifacts.value.path : null
      encryption_disabled    = secondary_artifacts.value.type != "NO_ARTIFACTS" ? secondary_artifacts.value.encryption_disabled : null
    }
  }
  dynamic "secondary_sources" {
    for_each = var.secondary_sources != null ? [var.secondary_sources] : []
    content {
      type                = secondary_sources.value.type
      source_identifier   = secondary_sources.value.source_identifier
      buildspec           = secondary_sources.value.buildspec
      git_clone_depth     = secondary_sources.value.git_clone_depth
      insecure_ssl        = secondary_sources.value.insecure_ssl
      location            = secondary_sources.value.location
      report_build_status = secondary_sources.value.report_build_status

      dynamic "git_submodules_config" {
        for_each = secondary_sources.value.git_submodules_config != null ? [secondary_sources.value.git_submodules_config] : []
        content {
          fetch_submodules = git_submodules_config.value.fetch_submodules
        }
      }

      dynamic "build_status_config" {
        for_each = secondary_sources.value.build_status_config != null ? [secondary_sources.value.build_status_config] : []
        content {
          context    = build_status_config.value.context
          target_url = build_status_config.value.target_url
        }
      }
    }
  }
  source_version = var.source_version
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      security_group_ids = [aws_security_group.sg.id]
      subnets            = vpc_config.value.subnet_ids
      vpc_id             = vpc_config.value.vpc_id
    }
  }
  tags = {
    "Name"    = local.naming_standard
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = var.standard.sub
    "Service" = var.standard.name
  }
}
