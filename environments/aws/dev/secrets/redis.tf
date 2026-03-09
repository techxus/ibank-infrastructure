############################################
# environments/aws/dev/secrets/redis.tf
# Redis auth token — generated once,
# stored in SSM SecureString, never in git.
############################################

resource "random_password" "redis_auth_token" {
  length  = 40
  special = false
}

resource "aws_ssm_parameter" "redis_auth_token" {
  name        = "/ibank/${var.env}/redis/auth-token"
  type        = "SecureString"
  value       = random_password.redis_auth_token.result
  description = "Redis auth token for ibank ${var.env}"
  tags        = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}