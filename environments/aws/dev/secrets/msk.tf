############################################
# environments/aws/dev/secrets/msk.tf
# MSK SASL/SCRAM credentials — generated once,
# stored in AWS Secrets Manager (required by MSK)
# and SSM for bootstrap reference.
############################################

resource "random_password" "msk_password" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "msk_credentials" {
  name        = "AmazonMSK_ibank-${var.env}-credentials"
  description = "MSK SASL/SCRAM credentials for ibank ${var.env}"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "msk_credentials" {
  secret_id = aws_secretsmanager_secret.msk_credentials.id
  secret_string = jsonencode({
    username = "ibankadmin"
    password = random_password.msk_password.result
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_ssm_parameter" "msk_secret_arn" {
  name        = "/ibank/${var.env}/msk/secret-arn"
  type        = "String"
  value       = aws_secretsmanager_secret.msk_credentials.arn
  description = "MSK Secrets Manager ARN for ibank ${var.env}"
  tags        = var.tags
}