inputs = {
  env          = "dev"
  cluster_name = "ibank-dev-eks"

  node_instance_type = "t3.medium"

  ng1_min_size     = 2
  ng1_max_size     = 4
  ng1_desired_size = 3

  ng2_min_size     = 1
  ng2_max_size     = 2
  ng2_desired_size = 1

  tailscale_auth_key_ssm_parameter_name = "/ibank/dev/tailscale/auth-key"

  tags = {
    Environment = "dev"
  }
}