include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name = "mock-cluster"
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
    cluster_name      = dependency.eks.outputs.cluster_name
    vault_kms_key_arn = dependency.kms.outputs.vault_unseal_key_arn
  }
)