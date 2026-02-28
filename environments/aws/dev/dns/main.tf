############################################
# environments/aws/dev/dns/main.tf
#
# PURPOSE:
# - Looks up existing Route53 hosted zone
# - Creates wildcard ACM certificate
# - Validates certificate via DNS automatically
#
# NOTE:
# bankit.cloud must already be registered
# in Route53 as a hosted zone.
############################################

data "aws_route53_zone" "this" {
  name         = var.domain
  private_zone = false
}

resource "aws_acm_certificate" "wildcard" {
  domain_name               = "*.${var.domain}"
  validation_method         = "DNS"
  subject_alternative_names = [var.domain]

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-wildcard"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "wildcard" {
  certificate_arn         = aws_acm_certificate.wildcard.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

resource "aws_ssm_parameter" "acm_certificate_id" {
  name  = "/ibank/${var.env}/acm-certificate-id"
  type  = "String"
  value = split("/", aws_acm_certificate.wildcard.arn)[1]
  tags  = var.tags
}