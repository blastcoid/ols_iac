output "route53_zone_id" {
  value       = aws_route53_zone.zone.zone_id
  description = "The unique ID of the Route53 hosted zone."
}

output "route53_name_servers" {
  value       = aws_route53_zone.zone.name_servers
  description = "A list of name servers in associated (sub) delegation set."
}

output "route53_arn" {
  value       = aws_route53_zone.zone.arn
  description = "The Amazon Resource Name (ARN) of the Route53 hosted zone."
}

output "primary_name_server" {
  value       = aws_route53_zone.zone.name_servers
  description = "A list of primary name servers for the Route53 hosted zone. This is typically the same as route53_name_servers."
}
