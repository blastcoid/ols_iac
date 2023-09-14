resource "random_password" "secret" {
  length           = 64
  override_special = "!#$%&*@"
  min_lower        = 10
  min_upper        = 10
  min_numeric      = 10
  min_special      = 5
}

resource "aws_ssm_parameter" "secret" {
  name            = "/${var.standard.unit}/${var.standard.env}/${var.standard.code}/${var.standard.feature}/${var.standard.sub}/github/GITHUB_SECRET"
  type            = "SecureString"
  value           = random_password.secret.result
  description     = "Secret parameter for /${var.standard.unit}/${var.standard.env}/${var.standard.code}/${var.standard.feature}/${var.standard.sub}/github/GITHUB_SECRET"
  key_id          = null
  tags = {
    "Name"     = "GITHUB_SECRET"
    "Unit"     = var.standard.unit
    "Env"      = var.standard.env
    "Code"     = var.standard.code
    "Feature"  = var.standard.feature
    "Sub"      = var.standard.sub
    "Provider" = "github"
  }
}

resource "aws_codepipeline_webhook" "webhook" {
  name            = "${local.naming_standard}-webhook"
  authentication  = var.webhook_authentication
  target_action   = var.webhook_target_action
  target_pipeline = aws_codepipeline.codepipeline.name
  dynamic "authentication_configuration" {
    for_each = var.webhook_authentication == "GITHUB_HMAC" || var.webhook_authentication == "IP" ? [var.authentication_configuration] : []
    content {
      secret_token     = var.webhook_authentication == "GITHUB_HMAC" ? aws_ssm_parameter.secret.value : null
      allowed_ip_range = var.webhook_authentication == "IP" ? authentication_configuration.value.allowed_ip_range : null
    }
  }

  dynamic "filter" {
    for_each = [var.webhook_filter]
    content {
      json_path = var.webhook_filter == null && var.standard.env == "prd" ? "$.action" : (
        var.webhook_filter == null && var.standard.env != "prd" ? "$.ref" : filter.value.json_path
      )
      match_equals = var.webhook_filter == null && var.standard.env == "prd" ? "published" : (
        var.webhook_filter == null && var.standard.env == "stg" ? "refs/heads/main" : (
          var.webhook_filter == null && (var.standard.env == "dev" || var.standard.env == "mstr") ? "refs/heads/dev" : filter.value.match_equals
        )
      )
    }
  }
}

resource "github_repository_webhook" "webhook" {
  repository = var.github_repository_name
  configuration {
    url          = aws_codepipeline_webhook.webhook.url
    content_type = "json"
    insecure_ssl = false
    secret       = aws_ssm_parameter.secret.value
  }
  events = length(var.webhook_events) <= 0 && var.standard.env == "prd" ? ["release"] : (
    length(var.webhook_events) <= 0 && var.standard.env != "prd" ? ["push"] : var.webhook_events
  )
}
