############################################
# environments/aws/dev/networking/msk.tf
#
# PURPOSE:
# Creates networking prerequisites for MSK.
# Crossplane references these when provisioning
# MSK clusters.
#
# Resources:
# - Security group → allows Kafka access from EKS nodes
############################################

resource "aws_security_group" "msk" {
  name        = "ibank-${var.env}-msk"
  description = "Allow Kafka from within VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Kafka SASL/SCRAM from VPC"
    from_port   = 9096
    to_port     = 9096
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
    Name = "ibank-${var.env}-msk"
    app  = "ibank-${var.env}-msk"
  })
}