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

inputs = merge(
  local.env_vars.inputs,
  {
    cluster_name = dependency.eks.outputs.cluster_name
  }
)