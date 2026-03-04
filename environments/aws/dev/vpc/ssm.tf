############################################
# environments/aws/dev/vpc/ssm.tf
# Writes VPC outputs to SSM so bootstrap
# and other automation can read them without
# hardcoding. Pattern works for dev/stage/prod
# by parameterizing on var.env.
############################################

resource "aws_ssm_parameter" "vpc_id" {
  name  = "/ibank/${var.env}/vpc/id"
  type  = "String"
  value = module.vpc.vpc_id
  tags  = var.tags
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/ibank/${var.env}/vpc/private-subnet-ids"
  type  = "String"
  value = join(",", module.vpc.private_subnet_ids)
  tags  = var.tags
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name  = "/ibank/${var.env}/vpc/cidr"
  type  = "String"
  value = var.vpc_cidr
  tags  = var.tags
}
