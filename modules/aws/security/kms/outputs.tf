output "key_arn" {
  value       = aws_kms_key.key.arn
  description = "The Amazon Resource Name (ARN) of the KMS key."
}

output "key_id" {
  value       = aws_kms_key.key.key_id
  description = "The globally unique identifier for the KMS key."
}

output "alias_arn" {
  value       = aws_kms_alias.alias.arn
  description = "The ARN of the KMS alias."
}

output "alias_name" {
  value       = aws_kms_alias.alias.name
  description = "The display name of the alias. Starts with 'alias/'."
}
