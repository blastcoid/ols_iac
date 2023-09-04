output "key_arn" {
  value = aws_kms_key.kms.arn
}

output "key_id" {
  value = aws_kms_key.kms.key_id
}

output "alias_arn" {
  value = aws_kms_alias.kms_alias.arn
}

output "alias_name" {
  value = aws_kms_alias.kms_alias.name
}