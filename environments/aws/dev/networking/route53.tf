############################################
# Private Route53 hosted zone for internal
# services reachable only through Tailscale
############################################

resource "aws_route53_zone" "private" {
  name = var.domain

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-private-zone"
  })
}