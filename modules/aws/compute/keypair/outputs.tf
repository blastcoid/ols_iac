# Keypair Outputs

output "key_name" {
  value       = aws_key_pair.key.key_name
  description = "The name of the key pair"
}

output "key_name_prefix" {
  value       = aws_key_pair.key.key_name_prefix
  description = "The key pair name prefix"
}

output "public_key" {
  value       = aws_key_pair.key.public_key
  description = "The SSH public key"
}

output "private_key" {
  value       = tls_private_key.node_key.private_key_pem
  description = "The SSH private key"
  sensitive   = true
}
