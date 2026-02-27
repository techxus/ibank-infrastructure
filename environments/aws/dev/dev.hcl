locals {
  env                 = "dev"
  cluster_name        = "ibank-dev-eks"
}

inputs = {
  env          = local.env
  cluster_name = local.cluster_name
  tags = {
    Environment = local.env
  }
}
