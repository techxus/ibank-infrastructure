############################################
# environments/aws/dev/vpc/terragrunt.hcl
# No dependencies — vpc runs first
############################################

include "root" {
  path = find_in_parent_folders("root.hcl")
}