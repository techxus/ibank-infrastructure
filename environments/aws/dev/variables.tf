############################################
# envs/aws/dev/eks/variables.tf
# Purpose:
# - Declare inputs for the DEV EKS stack.
# Student notes:
# - variables.tf declares "what you can configure".
# - terraform.tfvars sets "values for this environment".
############################################
variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}

variable "cluster_name_prefix" {
  description = "Prefix for the EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS control plane"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "If true, EKS API endpoint is reachable from the internet"
  type        = bool
}

variable "cluster_endpoint_private_access" {
  description = "If true, EKS API endpoint is reachable from inside the VPC"
  type        = bool
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
}

# Node group 1 sizes
variable "ng1_min_size" {
  type        = number
  description = "Min nodes for node group 1"
}
variable "ng1_max_size" {
  type        = number
  description = "Max nodes for node group 1"
}
variable "ng1_desired_size" {
  type        = number
  description = "Desired nodes for node group 1"
}

# Node group 2 sizes
variable "ng2_min_size" {
  type        = number
  description = "Min nodes for node group 2"
}
variable "ng2_max_size" {
  type        = number
  description = "Max nodes for node group 2"
}
variable "ng2_desired_size" {
  type        = number
  description = "Desired nodes for node group 2"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "az_count" {
  description = "Number of AZs"
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all AZs (cheaper)"
  type        = bool
  default     = true
}
