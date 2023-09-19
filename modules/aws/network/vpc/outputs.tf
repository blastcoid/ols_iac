# VPC outputs
output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC."
}

output "vpc_secondary_cidr_id" {
  value       = aws_vpc_ipv4_cidr_block_association.secondary_cidr.id
  description = "The ID of the secondary CIDR block association."
}

output "vpc_arn" {
  value       = aws_vpc.vpc.arn
  description = "The ARN of the VPC."
}

output "vpc_cidr_block" {
  value       = aws_vpc.vpc.cidr_block
  description = "The primary CIDR block of the VPC."
}

output "vpc_secondary_cidr_block" {
  value       = aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block
  description = "The secondary CIDR block of the VPC."
}

# Subnet outputs
output "node_id" {
  value       = aws_subnet.node.*.id
  description = "The IDs of the node subnets."
}

output "node_arn" {
  value       = aws_subnet.node.*.arn
  description = "The ARNs of the node subnets."
}

output "app_id" {
  value       = aws_subnet.node.*.id
  description = "The IDs of the app subnets."
}

output "app_arn" {
  value       = aws_subnet.node.*.arn
  description = "The ARNs of the app subnets."
}

output "data_id" {
  value       = aws_subnet.data.*.id
  description = "The IDs of the data subnets."
}

output "data_arn" {
  value       = aws_subnet.data.*.arn
  description = "The ARNs of the data subnets."
}

output "public_id" {
  value       = aws_subnet.public.*.id
  description = "The IDs of the public subnets."
}

output "public_arn" {
  value       = aws_subnet.public.*.arn
  description = "The ARNs of the public subnets."
}

# NAT Gateway outputs
output "nat_id" {
  value       = aws_nat_gateway.nat.*.id
  description = "The IDs of the NAT gateways."
}

output "nat_allocation_id" {
  value       = aws_nat_gateway.nat.*.allocation_id
  description = "The allocation IDs of the NAT gateways."
}

output "nat_public_ips" {
  value       = aws_nat_gateway.nat.*.public_ip
  description = "The public IPs of the NAT gateways."
}
