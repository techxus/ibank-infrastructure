############################################
# modules/aws/eks/outputs.tf
# Purpose:
# - Expose values other stacks need (like ALB Controller IRSA)
############################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS control plane endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group attached to the EKS control plane"
  value       = module.eks.cluster_security_group_id
}

############################################
# OIDC outputs (used for IRSA)
############################################

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC Provider for this cluster (used by IRSA)."
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "OIDC issuer host/path WITHOUT https:// (convenient for IRSA conditions)."
  value       = module.eks.oidc_provider
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL WITH https:// (source of truth from EKS API)."
  value       = module.eks.cluster_oidc_issuer_url
}