############################################
# environments/aws/dev/vpc/terraform.tfvars
############################################

region              = "us-east-1"
env                 = "dev"
cluster_name_prefix = "ibank"
vpc_cidr            = "10.0.0.0/16"
az_count            = 3
single_nat_gateway  = true