# Keypair Outputs

output "key_name" {
  value = aws_key_pair.key.key_name
}

output "key_name_prefix" {
  value = aws_key_pair.key.key_name_prefix
}

output "public_key" {
  value = aws_key_pair.key.public_key
}
