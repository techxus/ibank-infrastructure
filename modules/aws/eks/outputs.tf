############################################
# modules/aws/eks/outputs.tf
# Purpose:
# - Expose values other stacks need (like ALB Controller IRSA)
############################################

output "oidc_provider" {
  description = "OIDC issuer host/path WITHOUT https:// (convenient for IRSA conditions)."
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider."
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}