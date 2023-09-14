output "config_arn" {
  value       = { for k, v in aws_ssm_parameter.configs : k => v.arn }
  description = "The ARN of the SSM config parameters."
}

output "config_version" {
  value       = { for k, v in aws_ssm_parameter.configs : k => v.version }
  description = "The version of the SSM config parameters."
}

output "config_value" {
  value       = { for k, v in aws_ssm_parameter.configs : k => v.value }
  description = "The value of the SSM config parameters."
}

output "secret_arn" {
  value       = { for k, v in aws_ssm_parameter.secrets : k => v.arn }
  description = "The ARN of the SSM secret parameters."
}

output "secret_version" {
  value       = { for k, v in aws_ssm_parameter.secrets : k => v.version }
  description = "The version of the SSM secret parameters."
}

output "secret_value" {
  value       = { for k, v in aws_ssm_parameter.secrets : k => v.value }
  description = "The value of the SSM secret parameters."
  sensitive   = true
}