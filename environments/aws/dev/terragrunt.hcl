############################################
# environments/aws/dev/terragrunt.hcl
#
# PURPOSE:
# Points to root config.
# That's it. Nothing else needed here.
############################################

include "root" {
  path = find_in_parent_folders()
}
