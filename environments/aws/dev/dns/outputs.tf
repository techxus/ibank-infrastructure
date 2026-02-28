output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = data.aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "Route53 hosted zone name"
  value       = data.aws_route53_zone.this.name
}

output "acm_certificate_arn" {
  description = "Validated wildcard ACM certificate ARN"
  value       = aws_acm_certificate_validation.wildcard.certificate_arn
}

output "acm_certificate_id" {
  description = "ACM certificate ID"
  value       = split("/", aws_acm_certificate.wildcard.arn)[1]
}