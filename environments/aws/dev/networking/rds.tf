############################################
# environments/aws/dev/networking/rds.tf
#
# PURPOSE:
# Creates networking prerequisites for RDS.
# Crossplane references these when provisioning
# RDS instances via claims.
#
# Resources:
# - DB subnet group  → tells RDS which subnets to use
# - Security group   → only allows PostgreSQL from within VPC
############################################

resource "aws_db_subnet_group" "rds" {
  name        = "ibank-${var.env}-postgres"
  description = "RDS subnet group for iBank ${var.env}"
  subnet_ids  = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-postgres"
  })
}

resource "aws_security_group" "rds" {
  name        = "ibank-${var.env}-postgres"
  description = "Allow PostgreSQL from within VPC only"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
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
    Name = "ibank-${var.env}-postgres"
  })
}