output "alb_controller_role_arn" {
  description = "IRSA role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}

output "crossplane_role_arn" {
  description = "IRSA role ARN for Crossplane"
  value       = aws_iam_role.crossplane.arn
}

output "vault_role_arn" {
  description = "IRSA role ARN for Vault"
  value       = aws_iam_role.vault.arn
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns.arn
}