variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "oidc_provider_arn" {
  description = "EKS OIDC provider ARN for IRSA"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "EKS OIDC issuer URL for IRSA"
  type        = string
}

variable "vault_kms_key_arn" {
  description = "KMS key ARN for Vault unseal policy"
  type        = string
}