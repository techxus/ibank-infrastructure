############################################
# environments/aws/dev/networking/elasticache.tf
#
# PURPOSE:
# Creates networking prerequisites for Redis (ElastiCache).
# Crossplane references these when provisioning
# Redis replication groups.
#
# Resources:
# - ElastiCache subnet group → tells Redis which subnets to use
# - Security group           → allows Redis access from EKS nodes
############################################
resource "aws_elasticache_subnet_group" "redis" {
  name        = "ibank-${var.env}-redis"
  description = "Redis subnet group for iBank ${var.env}"
  subnet_ids  = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-redis"
    app  = "ibank-${var.env}-redis"
  })
}

resource "aws_security_group" "redis" {
  name        = "ibank-${var.env}-redis"
  description = "Allow Redis from within VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-redis"
    app  = "ibank-${var.env}-redis"
  })
}