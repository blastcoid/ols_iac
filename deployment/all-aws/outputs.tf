# KMS
output "kms_main_key_arn" {
  value       = module.kms_main.key_arn
}

output "kms_main_key_id" {
  value       = module.kms_main.key_id
}

output "kms_main_alias_arn" {
  value       = module.kms_main.alias_arn
}

output "kms_main_alias_name" {
  value       = module.kms_main.alias_name
}

# # VPC

# output "main_vpc_id" {
#   value = module.vpc_main.vpc_id
# }

# output "main_vpc_arn" {
#   value = module.vpc_main.vpc_arn
# }

# output "main_vpc_cidr_block" {
#   value = module.vpc_main.vpc_cidr_block
# }

# output "main_public_subnet_id" {
#   value = module.vpc_main.public_id
# }

# output "main_public_subnet_arn" {
#   value = module.vpc_main.public_arn
# }

# output "main_app_subnet_id" {
#   value = module.vpc_main.app_id
# }

# output "main_app_subnet_arn" {
#   value = module.vpc_main.app_arn
# }

# output "main_data_subnet_id" {
#   value = module.vpc_main.data_id
# }

# output "main_data_subnet_arn" {
#   value = module.vpc_main.data_arn
# }

# # Route53
# output "route53_blast_zone_id" {
#   value       = module.route53_blast.route53_zone_id
# }

# output "route53_blast_zone_name_servers" {
#   value       = module.route53_blast.route53_name_servers
# }

# # EC2 Keypair
# output "main_key_name" {
#   value       = module.keypair_main.key_name
# }

# output "main_key_name_prefix" {
#   value       = module.keypair_main.key_name_prefix
# }

# output "main_public_key" {
#   value       = module.keypair_main.public_key
# }