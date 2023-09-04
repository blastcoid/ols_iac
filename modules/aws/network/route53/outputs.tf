output "route53_zone_id" {
  value = aws_route53_zone.zone.zone_id
}

output "route53_name_servers" {
  value = aws_route53_zone.zone.name_servers
}

output "route53_arn" {
  value = aws_route53_zone.zone.arn
}

output "primary_name_server" {
  value = aws_route53_zone.zone.name_servers
}
