############################################
# Tailscale subnet router
# Provides private developer access to VPC resources
############################################

module "tailscale_router" {
  source = "../../../../modules/aws/tailscale"

  env    = var.env
  vpc_id = var.vpc_id

  public_subnet_id = var.public_subnet_ids[0]

  tags = var.tags

  tailscale_auth_key = var.tailscale_auth_key

  advertise_routes = [
    "10.0.100.0/24",
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}