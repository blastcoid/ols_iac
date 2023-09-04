#VPC
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_arn" {
  value = aws_vpc.vpc.arn
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

#Subnet
output "public_id" {
  value = aws_subnet.public.*.id
}

output "public_arn" {
  value = aws_subnet.public.*.arn
}

output "app_id" {
  value = aws_subnet.app.*.id
}

output "app_arn" {
  value = aws_subnet.app.*.arn
}

output "data_id" {
  value = aws_subnet.data.*.id
}

output "data_arn" {
  value = aws_subnet.data.*.arn
}