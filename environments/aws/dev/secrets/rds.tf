############################################
# environments/aws/dev/secrets/rds.tf
# RDS master password — generated once,
# stored in SSM SecureString, never in git.
############################################

resource "random_password" "rds_master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}?"
}

resource "aws_ssm_parameter" "rds_master_password" {
  name        = "/ibank/${var.env}/rds/master-password"
  type        = "SecureString"
  value       = random_password.rds_master.result
  description = "RDS master password for ibank ${var.env}"
  tags        = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "rds_master_username" {
  name  = "/ibank/${var.env}/rds/master-username"
  type  = "String"
  value = "ibankadmin"
  tags  = var.tags
}