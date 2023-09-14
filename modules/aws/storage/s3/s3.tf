locals {
  naming_standard     = "${var.standard.unit}-${var.standard.env}-${var.standard.code}-${var.standard.feature}-${var.standard.sub}"
  svc_naming_standard = try("${var.standard.unit}-${var.standard.env}-${var.standard.sub}-${var.standard.name}", null)
}


resource "aws_s3_bucket" "bucket" {
  bucket              = local.svc_naming_standard != null ? local.svc_naming_standard : local.naming_standard
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags = {
    "Name"    = local.naming_standard
    "Unit"    = var.standard.unit
    "Env"     = var.standard.env
    "Code"    = var.standard.code
    "Feature" = var.standard.feature
    "Sub"     = var.standard.sub
    "Service" = var.standard.name
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_accelerate_configuration" "accelerate" {
  count                 = var.bucket_accelerate_status != null ? 1 : 0
  bucket                = aws_s3_bucket.bucket.id
  status                = var.bucket_accelerate_status
  expected_bucket_owner = var.expected_bucket_owner
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  count  = var.bucket_object_ownership != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = var.bucket_object_ownership
  }
}

resource "aws_s3_bucket_acl" "acl" {
  count      = var.bucket_acl != null ? 1 : 0
  bucket     = aws_s3_bucket.bucket.id
  acl        = var.bucket_acl
  depends_on = [aws_s3_bucket_ownership_controls.ownership]
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  # policy = templatefile("iam_policies/bucket_policy.json", {
  #   account_id = var.account_id
  #   bucket_arn = aws_s3_bucket.bucket.arn
  # })
  policy = var.bucket_policy
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      id              = cors_rule.key
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count  = var.public_access_block != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "server_side_encryption" {
  count  = var.server_side_encryption != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  dynamic "rule" {
    for_each = var.server_side_encryption != null ? [var.server_side_encryption] : []
    content {
      apply_server_side_encryption_by_default {
        kms_master_key_id = rule.value.kms_master_key_id
        sse_algorithm     = rule.value.sse_algorithm
      }
      bucket_key_enabled = rule.value.bucket_key_enabled
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.versioning != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "versioning_configuration" {
    for_each = var.versioning != null ? [var.versioning] : []
    content {
      status     = versioning_configuration.value.enabled
      mfa_delete = versioning_configuration.value.mfa_delete
    }
  }
  mfa = var.versioning.mfa_delete == "Enabled" ? var.versioning_mfa : null
}

resource "aws_s3_bucket_website_configuration" "website" {
  count  = var.website != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "index_document" {
    for_each = var.website.index_document != null ? [var.website.index_document] : []
    content {
      suffix = index_document.value.suffix
    }
  }

  dynamic "error_document" {
    for_each = var.website.error_document != null ? [var.website.error_document] : []
    content {
      key = error_document.value.key
    }
  }
  routing_rules = var.website.routing_rules
  dynamic "redirect_all_requests_to" {
    for_each = var.website.redirect_all_requests_to != null && var.website.error_document == null ? [var.website.redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }

  dynamic "routing_rule" {
    for_each = var.website.routing_rules == null && var.website.routing_rule != null ? [var.website.routing_rule] : []
    content {
      dynamic "condition" {
        for_each = routing_rule.value.condition != null ? [routing_rule.value.condition] : []
        content {
          http_error_code_returned_equals = condition.value.http_error_code_returned_equals
          key_prefix_equals               = condition.value.key_prefix_equals
        }
      }

      dynamic "redirect" {
        for_each = routing_rule.value.redirect != null ? [routing_rule.value.redirect] : []
        content {
          host_name               = redirect.value.host_name
          http_redirect_code      = redirect.value.http_redirect_code
          protocol                = redirect.value.protocol
          replace_key_prefix_with = redirect.value.replace_key_prefix_with
          replace_key_with        = redirect.value.replace_key_prefix_with == null ? redirect.value.replace_key_with : null
        }
      }
    }
  }
}
