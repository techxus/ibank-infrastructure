############################################
# envs/aws/dev/eks/terraform.tfvars
# Purpose:
# - DEV environment values only.
############################################

region = "us-east-1"
env    = "dev"

cluster_name_prefix = "ibank"
cluster_version     = "1.29"

# Private-only API endpoint (production-grade)
cluster_endpoint_public_access  = false
cluster_endpoint_private_access = true

# Cost control (dev)
node_instance_type = "t3.small"

ng1_min_size     = 1
ng1_max_size     = 3
ng1_desired_size = 2

ng2_min_size     = 1
ng2_max_size     = 2
ng2_desired_size = 1

vpc_cidr           = "10.0.0.0/16"
az_count           = 3
single_nat_gateway = true
