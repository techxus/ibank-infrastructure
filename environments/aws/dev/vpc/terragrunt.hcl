############################################
# environments/aws/dev/vpc/root.hcl
# No dependencies — vpc runs first
############################################

include "root" {
  path = find_in_parent_folders("root.hcl")
}