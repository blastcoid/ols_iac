resource "aws_codepipeline_webhook" "webhook" {
  name            = "${var.name}-webhook"
  authentication  = var.webhook_authentication
  target_action   = var.webhook_target_action
  target_pipeline = aws_codepipeline.codepipeline.name
  dynamic "authentication_configuration" {
    for_each = var.webhook_authentication == "GITHUB_HMAC" || var.webhook_authentication == "IP" ? [var.authentication_configuration] : []
    content {
      secret_token     = var.webhook_authentication == "GITHUB_HMAC" ? var.github_secret : null
      allowed_ip_range = var.webhook_authentication == "IP" ? authentication_configuration.value.allowed_ip_range : null
    }
  }

  dynamic "filter" {
    for_each = [var.webhook_filter]
    content {
      json_path = var.webhook_filter == null && var.standard.Env == "prd" ? "$.action" : (
        var.webhook_filter == null && var.standard.Env != "prd" ? "$.ref" : filter.value.json_path
      )
      match_equals = var.webhook_filter == null && var.standard.Env == "prd" ? "published" : (
        var.webhook_filter == null && var.standard.Env == "stg" ? "refs/heads/main" : (
          var.webhook_filter == null && (var.standard.Env == "dev" || var.standard.Env == "mstr") ? "refs/heads/dev" : filter.value.match_equals
        )
      )
    }
  }
}

# resource "github_repository_webhook" "webhook" {
#   repository = var.github_repository_name
#   configuration {
#     url          = aws_codepipeline_webhook.webhook.url
#     content_type = "json"
#     insecure_ssl = false
#     secret       = aws_ssm_parameter.secret.value
#   }
#   events = length(var.webhook_events) <= 0 && var.standard.Env == "prd" ? ["release"] : (
#     length(var.webhook_events) <= 0 && var.standard.Env != "prd" ? ["push"] : var.webhook_events
#   )
# }
