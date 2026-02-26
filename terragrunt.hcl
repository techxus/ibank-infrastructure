############################################
# infrastructure/terragrunt.hcl
#
# PURPOSE:
# Root config inherited by all workspaces.
# Defines the S3 backend once so it never
# needs to be repeated in any workspace.
############################################

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "ibank-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ibank-terraform-locks"
    encrypt        = true
  }
}