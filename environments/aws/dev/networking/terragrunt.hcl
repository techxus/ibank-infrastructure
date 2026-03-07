include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("dev.hcl"))
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id             = "vpc-mock"
    public_subnet_ids  = ["subnet-mock-public-1", "subnet-mock-public-2"]
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
    vpc_cidr           = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
}

inputs = merge(
  local.env_vars.inputs,
  {
    vpc_id             = dependency.vpc.outputs.vpc_id
    public_subnet_ids  = dependency.vpc.outputs.public_subnet_ids
    private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
    vpc_cidr           = dependency.vpc.outputs.vpc_cidr
  }
)