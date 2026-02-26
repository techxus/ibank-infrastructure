############################################
# environments/aws/dev/eks/terraform.tfvars
############################################

region              = "us-east-1"
env                 = "dev"
cluster_name_prefix = "ibank"
cluster_version     = "1.29"

cluster_endpoint_public_access  = false
cluster_endpoint_private_access = true

node_instance_type = "t3.small"

ng1_min_size     = 1
ng1_max_size     = 3
ng1_desired_size = 2

ng2_min_size     = 1
ng2_max_size     = 2
ng2_desired_size = 1