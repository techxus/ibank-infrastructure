############################################
# global/terraform.tfvars
############################################

region      = "us-east-1"
github_org  = "techxus"
github_repo = "ibank-infrastructure"

service_names = [
  "ibank-user-service",
  "ibank-payment-service",
  "ibank-notification-service",
  "ibank-gateway-service"
]

tags = {
  Project     = "iBank"
  Environment = "global"
  ManagedBy   = "Terraform"
}