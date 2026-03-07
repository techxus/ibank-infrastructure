module "tailscale_router" {
  source = "../../../../modules/aws/tailscale"

  env    = var.env
  vpc_id = var.vpc_id

  public_subnet_id = var.public_subnet_ids[0]

  tags = var.tags

  tailscale_auth_key_ssm_parameter_name = var.tailscale_auth_key_ssm_parameter_name
  region                                = var.region

  advertise_routes = [
    "10.0.100.0/24",
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}