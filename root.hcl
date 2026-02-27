############################################
# root.hcl
#
# PURPOSE:
# - Configures S3 backend for all workspaces
# - Injects common variables into every
#   workspace so they never need to be
#   repeated in individual tfvars files.
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

inputs = {
  region              = "us-east-1"
  cluster_name_prefix = "ibank"
  domain              = "bankit.cloud"
  cluster_version     = "1.29"
  github_org          = "techxus"
  github_repo         = "ibank-infrastructure"
  service_names = [
    "ibank-user-service",
    "ibank-payment-service",
    "ibank-notification-service",
    "ibank-gateway-service"
  ]
  tags = {
    Project   = "iBank"
    ManagedBy = "Terraform"
  }
}