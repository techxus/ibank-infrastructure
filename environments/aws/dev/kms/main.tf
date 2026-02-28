############################################
# environments/aws/dev/kms/main.tf
#
# PURPOSE:
# Creates all KMS keys for this environment.
# Each key has a single specific purpose.
#
# Keys created:
# - Vault unseal key → Vault auto-unseals on restart
############################################

resource "aws_kms_key" "vault_unseal" {
  description             = "Vault auto-unseal key for iBank ${var.env}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name    = "ibank-${var.env}-vault-unseal"
    Purpose = "vault-unseal"
  })
}

resource "aws_kms_alias" "vault_unseal" {
  name          = "alias/ibank-${var.env}-vault-unseal"
  target_key_id = aws_kms_key.vault_unseal.key_id
}

resource "aws_ssm_parameter" "vault_kms_key_alias" {
  name  = "/ibank/${var.env}/vault-kms-key-alias"
  type  = "String"
  value = aws_kms_alias.vault_unseal.name
  tags  = var.tags
}