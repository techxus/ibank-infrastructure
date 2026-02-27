include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    oidc_provider_arn       = "arn:aws:iam::123456789012:oidc-provider/mock"
    cluster_oidc_issuer_url = "https://oidc.eks.us-east-1.amazonaws.com/id/mock"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
}

dependency "kms" {
  config_path = "../kms"

  mock_outputs = {
    vault_unseal_key_arn = "arn:aws:kms:us-east-1:123456789012:key/mock"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
}

inputs = merge(
  local.env_vars.inputs,
  {
    oidc_provider_arn       = dependency.eks.outputs.oidc_provider_arn
    cluster_oidc_issuer_url = dependency.eks.outputs.cluster_oidc_issuer_url
    vault_kms_key_arn       = dependency.kms.outputs.vault_unseal_key_arn
  }
)